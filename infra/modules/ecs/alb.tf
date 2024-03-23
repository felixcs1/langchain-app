resource "aws_lb_target_group" "this" {
  name        = "${var.app_name}-alb-tg"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

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

  subnets = var.public_subnets

  security_groups = [
    aws_security_group.http.id,
    aws_security_group.https.id,
    aws_security_group.ecs_egress_all.id,
  ]
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
