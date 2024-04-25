
resource "aws_security_group" "http" {
  name_prefix = "http-sg-"
  description = "Allow all HTTP/HTTPS traffic from public"
  vpc_id      = data.aws_vpc.this.id

  dynamic "ingress" {
    for_each = [80, 443]
    content {
      protocol    = "tcp"
      from_port   = ingress.value
      to_port     = ingress.value
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "this" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"

  subnets = data.aws_subnets.public.ids

  security_groups = [
    aws_security_group.http.id
  ]
}

resource "aws_lb_target_group" "this" {
  name = "${var.app_name}-alb-tg"

  # Port might not be needed here "Port on which targets receive traffic,
  # unless overridden when registering a specific target"
  port     = var.container_port
  protocol = "HTTP"

  # cant have "instance" here and network_mode = "awsvpc" in task definition
  target_type = "instance"
  vpc_id      = data.aws_vpc.this.id

  health_check {
    enabled  = true
    path     = "/healthz"
    interval = 30
  }

  depends_on = [aws_alb.this]

}

# Listen for HTTPS traffic
resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.https.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.this.arn
  port              = 80
  protocol          = "HTTP"

  # Redirects to https, so people can't request via http
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
