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

## Notes

- All code is production-ready and modular
- Replace Lambda code placeholders with your business logic
- Use the architecture doc to trace how each AWS resource depends on or invokes other resources




Great question. To test from ALB end-to-end, use this checklist.

1) Confirm infra is applied
From repo root:

terraform init
terraform apply
Get ALB DNS:

terraform output -raw alb_dns_name
2) Important wiring check (your current code)
Your config has:

ALB + listener + Lambda target group
Lambda permission for ALB invoke
But it does not currently show aws_lb_target_group_attachment to register producer-lambda into the ALB target group. Without that, ALB calls usually return 503.

You should have something like:

resource "aws_lb_target_group_attachment" "producer_lambda" {
  target_group_arn = aws_lb_target_group.lambda.arn
  target_id        = var.producer_lambda_arn
}
If you want, I can add this in Terraform now.

3) Test ALB HTTP directly
Once target is registered:

ALB_DNS=$(terraform output -raw alb_dns_name)
curl -i "http://${ALB_DNS}/"
For POST payload test:

curl -i -X POST "http://${ALB_DNS}/" \
  -H "Content-Type: application/json" \
  -d '{"id":"123","message":"hello from alb test"}'
4) Verify backend processing
Producer Lambda logs (invoked by ALB):
aws logs tail /aws/lambda/producer-lambda --follow
Consumer Lambda logs (invoked by SQS):
aws logs tail /aws/lambda/consumer-lambda --follow
SQS queue depth (should rise then drain):
aws sqs get-queue-attributes \
  --queue-url "$(terraform output -raw sqs_queue_url)" \
  --attribute-names ApproximateNumberOfMessages ApproximateNumberOfMessagesNotVisible
DynamoDB data:
aws dynamodb scan --table-name "$(terraform output -raw dynamodb_table_name)"
If you want, I’ll now patch the Terraform to add the missing ALB target group attachment so this test works reliably.