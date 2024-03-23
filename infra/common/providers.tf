terraform {

  required_version = ">=1.7.2, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.35.0"
    }
  }

  backend "s3" {
    bucket  = "terraform-state-010203040"
    key     = "common-infra/terraform.tfstate"
    region  = "eu-west-2"
    profile = "personal"
  }
}

provider "aws" {
  region  = "eu-west-2"
  profile = "personal"
}