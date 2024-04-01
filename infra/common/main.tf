resource "aws_ecs_cluster" "this" {
  name = "langserve-cluster"
}

resource "aws_ecr_repository" "backend" {
  name = "langserve"

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "frontend" {
  name = "langserve-frontend"

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}


module "vpc" {
  source   = "./modules/vpc"
  vpc_name = "felix-vpc-custom"

  # Careful, NAT Gateway is Expensive!
  # $0.05 per GB Data Processed by NAT Gateways
  # $0.05 per NAT Gateway Hour
  enable_nat_gateway = false
}

output "backend_repo_url" {
  value = aws_ecr_repository.backend.repository_url
}

output "frontend_repo_url" {
  value = aws_ecr_repository.frontend.repository_url
}
