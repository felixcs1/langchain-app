terraform {

  required_version = ">=1.7.2, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.35.0"
    }
  }

  backend "s3" {}

}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      Service    = "langserve-app"
      Owner      = "Felix Stephenson"
      Repository = "felixcs1/langchain-app"
    }
  }
}
