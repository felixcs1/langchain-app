resource "aws_security_group" "ec2_security_group" {
  name        = "${var.app_name}-ec2-sg"
  description = "HTTP traffic"
  vpc_id      = data.aws_vpc.this.id

  # Enable ssh external server connection:
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- ECS Node SG ---
resource "aws_security_group" "ecs_node_sg" {
  name_prefix = "demo-ecs-node-sg-"
  vpc_id      = data.aws_vpc.this.id

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



# For EFS
# "You have to allow NFS traffic from the container to the EFS fs.
# For this, you need a Security Group for the ECS container and an SG for
# the EFS mount target. Create an ingress rule in the EFS SG that allows
# tcp traffic on port 2049 from the container’s SG and you are good to go"
# https://opsdocks.com/posts/use-aws-ecs-with-efs/
resource "aws_security_group" "ingress_for_efs" {
  name        = "${var.app_name}-ingress-efs"
  description = "Allow ingress to API"
  vpc_id      = data.aws_vpc.this.id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]

    security_groups = [
      aws_security_group.ec2_security_group.id
    ]
  }
}
