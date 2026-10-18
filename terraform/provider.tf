# Terraform is the "Construction Crew": Terraform reads configuration files (.tf) and sends orders to LocalStack saying: "Hey, create a DynamoDB table named X, and deploy a Lambda function named Y using this zipped-up code."
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  # Redirects Terraform to talk straight to your LocalStack engine
  endpoints {
    sts            = "http://localhost.localstack.cloud:4566"
    ecr            = "http://localhost.localstack.cloud:4566"
    ecs            = "http://localhost.localstack.cloud:4566"
    ec2            = "http://localhost.localstack.cloud:4566"
    scheduler         = "http://localhost.localstack.cloud:4566"
    sqs         = "http://localhost.localstack.cloud:4566"
    lambda         = "http://localhost.localstack.cloud:4566"
    iam            = "http://localhost.localstack.cloud:4566"
    dynamodb       = "http://localhost.localstack.cloud:4566"
    eventbridge    = "http://localhost.localstack.cloud:4566"
    eks            = "http://localhost.localstack.cloud:4566"
    secretsmanager = "http://localhost.localstack.cloud:4566"
    cloudwatch = "http://localhost.localstack.cloud:4566"
    # cloudwatchlog = "http://localhost.localstack.cloud:4566"
    cloudwatchlogs = "http://localhost.localstack.cloud:4566"
  }
}
