resource "aws_lb_target_group" "this" {
  name = "${var.app_name}-alb-tg"

  # Port might not be needed here "Port on which targets receive traffic,
  # unless overridden when registering a specific target"
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.this.id

  health_check {
    enabled  = true
    path     = "/healthz"
    interval = 60
  }

  depends_on = [aws_alb.this]

}

resource "aws_alb" "this" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"

  subnets = data.aws_subnets.public.ids

  security_groups = [
    aws_security_group.http.id,
    aws_security_group.https.id,
    aws_security_group.ecs_egress_all.id,
  ]

  # Requires permissions set on the bucket
  access_logs {
    bucket  = "alb-access-logs-12345"
    enabled = false
  }
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
