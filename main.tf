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

module "producer_lambda_role" {
  source = "./modules/producer_lambda_role"
  sqs_arn = module.sqs.queue_arn
}

module "consumer_lambda_role" {
  source = "./modules/consumer_lambda_role"
  sqs_arn = module.sqs.queue_arn
}


module "producer_lambda" {
  source = "./modules/producer_lambda"
  lambda_role_arn        = module.producer_lambda_role.role_arn
  lambda_zip             = var.producer_lambda_zip
  environment_variables  = {
    SQS_QUEUE_URL = module.sqs.queue_url
  }
}

module "alb" {
  source = "./modules/alb"
  vpc_id               = module.network.vpc_id
  subnets              = module.network.public_subnets
  security_groups      = [module.network.alb_security_group_id]
  producer_lambda_arn  = module.producer_lambda.lambda_arn
}

module "sqs" {
  source = "./modules/sqs"
}

module "consumer_lambda" {
  source = "./modules/consumer_lambda"
  lambda_role_arn        = module.consumer_lambda_role.role_arn
  lambda_zip             = var.consumer_lambda_zip
  environment_variables  = {
    DYNAMODB_TABLE_NAME = module.dynamodb.table_name
  }
  sqs_arn                = module.sqs.queue_arn
}

module "dynamodb" {
  source = "./modules/dynamodb"
}
