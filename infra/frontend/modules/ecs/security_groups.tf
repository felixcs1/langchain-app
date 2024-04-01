# For ALB
resource "aws_security_group" "http" {
  name        = "${var.app_name}-http"
  description = "HTTP traffic"
  vpc_id      = data.aws_vpc.this.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# For ALB
resource "aws_security_group" "https" {
  name        = "${var.app_name}-https"
  description = "HTTPS traffic"
  vpc_id      = data.aws_vpc.this.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# For ALB and ECS service
resource "aws_security_group" "ecs_egress_all" {
  name        = "${var.app_name}-egress-all"
  description = "Allow all outbound traffic"
  vpc_id      = data.aws_vpc.this.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# For the web app running on ECS service
resource "aws_security_group" "ingress_api" {
  name        = "${var.app_name}-ingress-api"
  description = "Allow ingress to API"
  vpc_id      = data.aws_vpc.this.id

  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
