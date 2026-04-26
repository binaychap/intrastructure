variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "producer_lambda_zip" {
  description = "Path to the producer Lambda deployment package (.zip)"
  type        = string
  default     = "producer-lambda.zip"
}

variable "consumer_lambda_zip" {
  description = "Path to the consumer Lambda deployment package (.zip)"
  type        = string
  default     = "consumer-lambda.zip"
}
