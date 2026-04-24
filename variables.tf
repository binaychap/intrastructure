variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID for ALB and Lambdas"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "alb_security_groups" {
  description = "Security groups for ALB"
  type        = list(string)
}

variable "producer_lambda_role_arn" {
  description = "IAM role ARN for producer Lambda"
  type        = string
}

variable "producer_lambda_zip" {
  description = "Path to producer Lambda deployment package (.zip)"
  type        = string
}

variable "consumer_lambda_role_arn" {
  description = "IAM role ARN for consumer Lambda"
  type        = string
}

variable "consumer_lambda_zip" {
  description = "Path to consumer Lambda deployment package (.zip)"
  type        = string
}
