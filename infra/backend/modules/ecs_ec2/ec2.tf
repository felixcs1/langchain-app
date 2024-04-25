locals {
  service_name = "${var.app_name}-service-ec2"
}


resource "aws_launch_template" "my_first_template" {
  name = "my_first_template"

  # ami-0bb067f06d08ad2fb - recommended from cmd
  # aws ssm get-parameters --names /aws/service/ecs/optimized-ami/amazon-linux-2/gpu/recommended --region eu-west-2
  image_id      = "ami-0102fbd5d97709a69" # ecs-gpu
  instance_type = var.instance_type

  key_name = aws_key_pair.gen_key_pair.key_name

  # https://medium.com/codex/deep-learning-setup-ecs-gpu-task-on-ubuntu-part-4-46c364d1b556
  user_data = base64encode(<<-EOF
        #!/bin/bash
        sudo mkdir -p /etc/ecs && sudo touch /etc/ecs/ecs.config
        echo ECS_CLUSTER=${var.ecs_cluster_name} >> /etc/ecs/ecs.config;
        echo ECS_ENABLE_GPU_SUPPORT=true >> /etc/ecs/ecs.config;
      EOF
  )

  # echo ECS_NVIDIA_RUNTIME=nvidia >> /etc/ecs/ecs.config;

  iam_instance_profile { arn = aws_iam_instance_profile.ecs_node.arn }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2_security_group.id, aws_security_group.ecs_node_sg.id]
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "test"
    }
  }
}


resource "aws_autoscaling_group" "ecs_asg" {
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1
  vpc_zone_identifier = data.aws_subnets.public.ids

  launch_template {
    id = aws_launch_template.my_first_template.id
    # Setting this and instance_refresh block
    # will mean instances are refreshes on template change
    version = aws_launch_template.my_first_template.latest_version
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}


# For some reason when using an ecs optimized ec2 ami I cnat
# connect with instance connect so I make a key pair here
resource "tls_private_key" "gen_tls_pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Automatically generated key_pair 'gen_key_pair':
resource "aws_key_pair" "gen_key_pair" {
  key_name   = "ec2_key_pair"
  public_key = tls_private_key.gen_tls_pk.public_key_openssh
}

# Saves a local file
resource "local_file" "gen_key_pair" {
  content  = tls_private_key.gen_tls_pk.private_key_pem
  filename = "ec2_key_pair.pem"
}
