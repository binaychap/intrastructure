terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}


provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./modules/network"
}


module "alb" {
  source = "./modules/alb"
  vpc_id          = module.network.vpc_id
  subnets         = module.network.public_subnets
  security_groups = [module.network.alb_security_group_id]
}

module "producer_lambda" {
  source = "./modules/producer_lambda"
  lambda_role_arn        = var.producer_lambda_role_arn
  lambda_zip             = var.producer_lambda_zip
  environment_variables  = {
    SQS_QUEUE_URL = module.sqs.queue_url
  }
  alb_arn                = module.alb.dns_name # Replace with correct ALB ARN output if needed
}

module "sqs" {
  source = "./modules/sqs"
}

module "consumer_lambda" {
  source = "./modules/consumer_lambda"
  lambda_role_arn        = var.consumer_lambda_role_arn
  lambda_zip             = var.consumer_lambda_zip
  environment_variables  = {
    DYNAMODB_TABLE_NAME = module.dynamodb.table_name
  }
  sqs_arn                = module.sqs.queue_url # Replace with correct SQS ARN output if needed
}

module "dynamodb" {
  source = "./modules/dynamodb"
}
