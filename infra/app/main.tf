locals {
  app_name         = "langserve-app"
  vpc_name         = "felix-vpc-custom"
  ecr_repo_name    = "langserve"
  ecs_cluster_name = "langserve-cluster"
  image_tag        = "latest"
  container_port   = 8080
  region           = "eu-west-2"
  task_cpu         = 4096
  task_memory      = 8192
}


module "ecs_cluster" {
  source = "./modules/ecs"

  vpc_name         = local.vpc_name
  ecr_repo_name    = local.ecr_repo_name
  ecs_cluster_name = local.ecs_cluster_name
  container_port   = local.container_port
  app_name         = local.app_name
  image_tag        = local.image_tag
  aws_region       = local.region
  task_cpu         = local.task_cpu
  task_memory      = local.task_memory

  # This should be true, but to avoid high NAT gateway costs
  # I am turning this off during development / learning and
  # putting everything in public subnets for now
  ecs_service_in_private_subnets = false
}

module "config" {
  source = "./modules/app_config"
}
