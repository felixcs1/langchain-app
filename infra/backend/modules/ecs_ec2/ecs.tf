resource "aws_cloudwatch_log_group" "app" {
  name = "/ecs/${local.service_name}"

  retention_in_days = 14
}


resource "aws_cloudwatch_log_group" "ollama" {
  name = "/ecs/ollama"

  retention_in_days = 14
}

# Capacity Provider acts as a link between ECS Cluster and Autoscaling Group and is linked to both resources
# https://nexgeneerz.io/aws-computing-with-ecs-ec2-terraform/#Autoscaling_on_ECS
# TODO: add aws_appautoscaling_target and aws_appautoscaling_policy for memory and cpu usage
resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = "test1"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn

    managed_scaling {
      maximum_scaling_step_size = 5
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 3
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "example" {
  cluster_name = var.ecs_cluster_name

  capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
  }
}


resource "aws_ecs_task_definition" "new" {
  family = "${var.app_name}-task-ec2"

  # For ec2 in ECS awsvpc did not let me access internet from inside a container
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#network_mode
  # TODO what shoudl this be set to? In conjuction with alb target type
  network_mode             = "host"
  requires_compatibilities = ["EC2"] # not needed to be set for EC2

  cpu    = var.task_cpu
  memory = var.task_memory

  # Needed for logs / ECR etc when using fargate. With EC2 its expected
  # you have the roles for logs and ECR on the instances
  # Gives the ECS service permission to do things like read an image from an ECR repository, and lookup secrets in SecretsManager
  execution_role_arn = data.aws_iam_role.ecs_execution_role.arn

  # Gives the software running inside the ECS task/container permission to access AWS resources.
  # For e.g EFS
  task_role_arn = data.aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "ollama-container"
      image     = "ollama/ollama"
      cpu       = var.task_cpu - 10
      memory    = var.task_memory - 512
      essential = false # Required for it to be a dependency of the app container
      portMappings = [
        {
          containerPort = 11434
        }
      ]
      # For each container that has a GPU resource requirement that's specified in the container definition,
      # Amazon ECS sets the container runtime to be the NVIDIA container runtime.
      # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-gpu.html
      resourceRequirements = [
        {
          type  = "GPU",
          value = "1"
        }
      ]
      environment = [
        {
          name  = "OLLAMA_DEBUG"
          value = "1"
        },
      ]

      # N.B can check this on the container with 'df -h'

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-region        = var.aws_region
          awslogs-group         = aws_cloudwatch_log_group.ollama.name
          awslogs-stream-prefix = "${local.service_name}-ec2"
        }
      }
      mountPoints : [
        {
          sourceVolume : "efs-persist",
          containerPath : "/root/.ollama"
        }
      ]
    },
    {
      name  = "${var.app_name}-container"
      image = "${data.aws_ecr_repository.this.repository_url}:${var.image_tag}"

      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
        },
      ]
      environment = var.container_env

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-region        = var.aws_region
          awslogs-group         = aws_cloudwatch_log_group.app.name
          awslogs-stream-prefix = local.service_name
        }
      }
    },
  ])

  volume {
    name = "efs-persist"

    efs_volume_configuration {
      file_system_id = aws_efs_file_system.efs_volume.id
      root_directory = "/"
    }
  }
}

resource "aws_ecs_service" "new" {
  name            = local.service_name
  cluster         = data.aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.new.arn
  desired_count   = 1

  # enables `aws ecs execute-command` cli commands against containers
  # requires task_role_arn in task definition
  enable_execute_command = true

  # Only required when using network_mode "awsvpc"
  # network_configuration {
  #   assign_public_ip = false
  #   security_groups = [
  #     aws_security_group.ec2_security_group.id
  #   ]
  #   subnets = var.ecs_service_in_private_subnets ? data.aws_subnets.private.ids : data.aws_subnets.public.ids
  # }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
    base              = 1
    weight            = 100
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "${var.app_name}-container"
    container_port   = var.container_port
  }
}
