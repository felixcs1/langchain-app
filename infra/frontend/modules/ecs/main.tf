locals {
  service_name = "${var.app_name}-service"
}


resource "aws_cloudwatch_log_group" "app" {
  name = "/ecs/${local.service_name}"

  retention_in_days = 14
}


resource "aws_ecs_task_definition" "this" {
  family = "${var.app_name}-task"

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = var.task_cpu
  memory = var.task_memory

  # Needed for logs / ECR etc when using fargate. With EC2 its expected
  # you have the roles for logs and ECR on the instances
  # Gives the ECS service permission to do things like read an image from an ECR repository, and lookup secrets in SecretsManager
  execution_role_arn = data.aws_iam_role.ecs_execution_role.arn

  # Only required if enable_execute_command = true in the service
  # gives the software running inside the ECS task/container permission to access AWS resources.
  # For e.g EFS
  task_role_arn = data.aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "${var.app_name}-container"
      image = "${data.aws_ecr_repository.this.repository_url}:${var.image_tag}"

      cpu       = 256
      memory    = 512
      essential = true # need at least on essential container
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
}


resource "aws_ecs_service" "this" {
  name            = local.service_name
  cluster         = data.aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  # enables `aws ecs execute-command` cli commands against containers
  # requires task_role_arn in task definition
  enable_execute_command = true

  network_configuration {
    assign_public_ip = true
    security_groups = [
      aws_security_group.ecs_egress_all.id,
      aws_security_group.ingress_api.id
    ]
    subnets = data.aws_subnets.private.ids
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "${var.app_name}-container"
    container_port   = var.container_port
  }
}
