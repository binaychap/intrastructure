# AWS Serverless Production Architecture (ALB → Lambda → SQS → Lambda → DynamoDB)

This project is a production-ready, modular Terraform package for deploying a serverless event-driven architecture on AWS:

- **ALB**: Application Load Balancer as the entry point
- **Producer Lambda**: Triggered by ALB
- **SQS**: Decouples producer and consumer
- **Consumer Lambda**: Triggered by SQS
- **DynamoDB**: Persistent storage

## Structure

- `modules/alb`: ALB resources
- `modules/producer_lambda`: Producer Lambda resources
- `modules/sqs`: SQS resources
- `modules/consumer_lambda`: Consumer Lambda resources
- `modules/dynamodb`: DynamoDB resources

## Usage

1. Configure variables as needed
2. Run `terraform init && terraform apply`

## Notes

- All code is production-ready and modular
- Replace Lambda code placeholders with your business logic
