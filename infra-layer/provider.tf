terraform {
  backend "s3" {
    bucket = "tfstate-3-tier"
    key = "tf/terraform.tfstate"
    region = "eu-north-1"
    profile = "shared"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = "~> 1.10"
}

provider "aws" {
  region = var.region
  profile = var.environment_identifier
}