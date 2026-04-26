variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "producer_lambda_source_dir" {
  description = "Path to producer Lambda source directory"
  type        = string
  default     = "lambda/producer"
}

variable "consumer_lambda_source_dir" {
  description = "Path to consumer Lambda source directory"
  type        = string
  default     = "lambda/consumer"
}
