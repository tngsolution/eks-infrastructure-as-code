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
  region = var.region

  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Stack       = "nat-instance"
      Environment = var.environment
      Team        = "DEVOPS"
      Project     = "SAA-C02"
    }
  }
}
