# AWS Serverless Production Architecture (ALB → Lambda → SQS → Lambda → DynamoDB)

This project is a production-ready, modular Terraform package for deploying a serverless event-driven architecture on AWS:

- **ALB**: Application Load Balancer as the entry point
- **Producer Lambda**: Triggered by ALB
- **SQS**: Decouples producer and consumer
- **Consumer Lambda**: Triggered by SQS
- **DynamoDB**: Persistent storage

## Architecture Documentation

Detailed AWS resource relationships, interaction matrix, and diagram are documented in:

- `docs/aws-resource-interactions.md`
- Mermaid source: `docs/aws-resource-interactions.mmd`
- Generated PNG path: `docs/aws-resource-interactions-diagram.png`

## Structure

- `modules/network`: VPC, public subnets, IGW, route table, ALB security group
- `modules/alb`: ALB resources
- `modules/producer_lambda_role`: Producer Lambda IAM role
- `modules/producer_lambda`: Producer Lambda resources
- `modules/sqs`: SQS resources
- `modules/consumer_lambda_role`: Consumer Lambda IAM role and SQS permissions
- `modules/consumer_lambda`: Consumer Lambda resources
- `modules/dynamodb`: DynamoDB resources
- `docs/aws-resource-interactions.md`: End-to-end interactions and architecture diagram

## Usage

1. Configure variables as needed
2. Run `terraform init && terraform apply`
3. (Optional) Generate architecture PNG:
   `npx -y @mermaid-js/mermaid-cli -i docs/aws-resource-interactions.mmd -o docs/aws-resource-interactions-diagram.png -b white -t default`
4. (Optional) Or use Make:
   `make diagram`
5. Lambda ZIPs are built automatically by Terraform from `lambda/producer` and `lambda/consumer` during plan/apply.

## Notes

- All code is production-ready and modular
- Replace Lambda code placeholders with your business logic
- Use the architecture doc to trace how each AWS resource depends on or invokes other resources

## End-to-End Pipeline Test (ALB -> SQS -> Consumer)

1. Apply infrastructure:
   `terraform init && terraform apply`
2. Get ALB DNS:
   `terraform output -raw alb_dns_name`
3. Send test request through ALB:
   `ALB_DNS=$(terraform output -raw alb_dns_name) && curl -i "http://${ALB_DNS}/"`
4. Tail Lambda logs:
   - `aws logs tail /aws/lambda/producer-lambda --since 10m --follow --region us-east-1`
   - `aws logs tail /aws/lambda/consumer-lambda --since 10m --follow --region us-east-1`
5. Check SQS queue depth:
   `aws sqs get-queue-attributes --queue-url "$(terraform output -raw sqs_queue_url)" --attribute-names ApproximateNumberOfMessages ApproximateNumberOfMessagesNotVisible --region us-east-1`
6. Confirm DynamoDB writes:
   `aws dynamodb scan --table-name "$(terraform output -raw dynamodb_table_name)" --region us-east-1`