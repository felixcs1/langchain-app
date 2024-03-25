locals {
  app_name       = "langserve-app"
  vpc_name       = "felix-vpc"
  ecr_repo_name  = "langserve"
  image_tag      = "latest"
  container_port = 8080
  region         = "eu-west-2"
  task_cpu       = 256
  task_memory    = 512
}


module "ecs_cluster" {
  source = "./modules/ecs"

  vpc_name       = local.vpc_name
  ecr_repo_name  = local.ecr_repo_name
  container_port = local.container_port
  app_name       = local.app_name
  image_tag      = local.image_tag
  aws_region     = local.region
  task_cpu       = local.task_cpu
  task_memory    = local.task_memory
}
