locals {
  app_name         = "langserve-app"
  vpc_name         = "felix-vpc-custom"
  ecr_repo_name    = "langserve"
  ecs_cluster_name = "langserve-cluster"
  image_tag        = "latest"
  container_port   = 8080
  region           = "eu-west-2"
  task_cpu         = 1024
  task_memory      = 512
}


# module "ecs_fargate_cluster" {
#   source = "./modules/ecs"

#   vpc_name         = local.vpc_name
#   ecr_repo_name    = local.ecr_repo_name
#   ecs_cluster_name = local.ecs_cluster_name
#   container_port   = local.container_port
#   app_name         = local.app_name
#   image_tag        = local.image_tag
#   aws_region       = local.region
#   task_cpu         = local.task_cpu
#   task_memory      = local.task_memory

#   container_env = [
#     {
#       name  = "OLLAMA_URL"
#       value = "localhost"
#     },
#   ]

#   # This should be true, but to avoid high NAT gateway costs
#   # I am turning this off during development / learning and
#   # putting everything in public subnets for now
#   ecs_service_in_private_subnets = false
# }


module "ecs_ec2_cluster" {

  # Resources used for development
  # https://nexgeneerz.io/aws-computing-with-ecs-ec2-terraform
  # https://spacelift.io/blog/terraform-ecs

  source = "./modules/ecs_ec2"

  vpc_name         = local.vpc_name
  ecr_repo_name    = local.ecr_repo_name
  ecs_cluster_name = local.ecs_cluster_name
  container_port   = 8080
  app_name         = local.app_name
  image_tag        = local.image_tag
  aws_region       = local.region

  # G4 pricing https://aws.amazon.com/ec2/instance-types/g4/
  # needed to up account quota to allow G instances: https://eu-west-2.console.aws.amazon.com/servicequotas/home/services/ec2/quotas
  instance_type = "g4dn.xlarge"
  task_cpu      = 2048
  task_memory   = 4096

  container_env = [
    {
      name  = "OLLAMA_URL"
      value = "localhost"
    },
  ]


  # This should be true, but to avoid high NAT gateway costs
  # I am turning this off during development / learning and
  # putting everything in public subnets for now
  ecs_service_in_private_subnets = false
}
