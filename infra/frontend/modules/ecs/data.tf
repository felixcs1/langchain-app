data "aws_ecr_repository" "this" {
  name = var.ecr_repo_name
}

data "aws_ecs_cluster" "this" {
  cluster_name = var.ecs_cluster_name
}


data "aws_vpc" "this" {
  state = "available"

  tags = {
    Name = var.vpc_name
  }
}


data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  tags = {
    Private = "true"
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  tags = {
    Public = "true"
  }
}

data "aws_iam_role" "ecs_execution_role" {
  name = "ECSExecutionRole"
}

data "aws_iam_role" "ecs_task_role" {
  name = "ECSTaskRole"
}
