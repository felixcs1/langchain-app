variable "repo_name" {
  type    = string
  default = "langserve"
}

variable "vpc_name" {
  type    = string
  default = "felix-vpc"
}


data "aws_availability_zones" "available_zones" {
  state = "available"
}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = "10.0.0.0/16"

  # For multiple AZs (slower to deploy)
  azs             = data.aws_availability_zones.available_zones.names
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false # Not sure what this is so turn off


  # used to pick up in data resources
  private_subnet_tags = {
    Private = "true"
  }

  public_subnet_tags = {
    Public = "true"
  }

  tags = {
    Terraform = "true"
  }
}


resource "aws_ecr_repository" "this" {
  name = var.repo_name

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}



output "repo_url" {
  value = aws_ecr_repository.this.repository_url
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
