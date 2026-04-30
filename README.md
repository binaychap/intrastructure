# AWS Serverless Production Architecture (ALB -> Lambda -> SQS -> Lambda -> DynamoDB)

This project deploys a modular, event-driven serverless architecture on AWS using Terraform:

- Internet-facing **Application Load Balancer** (ALB)
- **Producer Lambda** invoked by ALB
- **SQS** queue for decoupling
- **Consumer Lambda** triggered by SQS event source mapping
- **DynamoDB** table for persistence

## What's Implemented

- Public network foundation for ALB:
  - VPC + public subnets
  - Internet Gateway
  - Public route table (`0.0.0.0/0 -> IGW`) and subnet associations
- ALB to Lambda integration:
  - ALB listener forwards to Lambda target group
  - Lambda invoke permission for ALB principal
  - Lambda target registration via `aws_lb_target_group_attachment`
- SQS integration:
  - Queue exports both `queue_url` and `queue_arn`
  - Producer receives `SQS_QUEUE_URL` env var
  - Consumer uses SQS event source mapping with queue ARN
- IAM updates:
  - Producer role includes `sqs:SendMessage` on queue ARN
  - Consumer role includes `Receive/Delete/Attributes/Visibility` permissions on queue ARN
- Lambda packaging:
  - ZIPs are built automatically during Terraform run using `hashicorp/archive`
  - Lambda updates are tracked via `source_code_hash`

## Architecture Documentation

- `docs/aws-resource-interactions.md` - detailed interaction matrix and flow
- `docs/aws-resource-interactions.mmd` - Mermaid source
- `docs/aws-resource-interactions-diagram.png` - rendered diagram image

## Project Structure

- `main.tf` - root module wiring and automatic Lambda ZIP build (`archive_file`)
- `variables.tf` - root inputs, including Lambda source directories
- `modules/network` - VPC, subnets, IGW, routes, ALB security group
- `modules/alb` - ALB, listener, lambda target group, permission, attachment
- `modules/producer_lambda_role` - producer Lambda IAM role + SQS send policy
- `modules/producer_lambda` - producer Lambda function
- `modules/sqs` - SQS queue and outputs
- `modules/consumer_lambda_role` - consumer Lambda IAM role + SQS consume policy
- `modules/consumer_lambda` - consumer Lambda + SQS event source mapping
- `modules/dynamodb` - DynamoDB table
- `lambda/producer` - producer Lambda source
- `lambda/consumer` - consumer Lambda source

## Prerequisites

- Terraform `>= 1.3.0`
- AWS credentials configured for your target account/region
- AWS CLI installed (for verification commands)
- Node.js/npm (only needed if you want to regenerate diagram PNG via Mermaid CLI)

## Deploy

1. Initialize providers:
   `terraform init`
2. Apply infrastructure:
   `terraform apply`

Note: Lambda ZIPs are generated automatically from:

- `lambda/producer` -> `producer-lambda.zip`
- `lambda/consumer` -> `consumer-lambda.zip`

So after Lambda code changes, run `terraform apply` again (no manual zipping needed).

## End-to-End Pipeline Test (ALB -> SQS -> Consumer)

1. Get ALB DNS:
   `terraform output -raw alb_dns_name`
2. Send a request through ALB:
   `ALB_DNS=$(terraform output -raw alb_dns_name) && curl -i "http://${ALB_DNS}/"`
3. Tail producer logs:
   `aws logs tail /aws/lambda/producer-lambda --since 10m --follow --region us-east-1`
4. Tail consumer logs:
   `aws logs tail /aws/lambda/consumer-lambda --since 10m --follow --region us-east-1`
5. Check queue depth:
   `aws sqs get-queue-attributes --queue-url "$(terraform output -raw sqs_queue_url)" --attribute-names ApproximateNumberOfMessages ApproximateNumberOfMessagesNotVisible --region us-east-1`
6. Confirm DynamoDB writes:
   `aws dynamodb scan --table-name "$(terraform output -raw dynamodb_table_name)" --region us-east-1`

## Diagram Commands

- Generate diagram:
  `make diagram`
- Or directly:
  `npx -y @mermaid-js/mermaid-cli -i docs/aws-resource-interactions.mmd -o docs/aws-resource-interactions-diagram.png -b white -t default`