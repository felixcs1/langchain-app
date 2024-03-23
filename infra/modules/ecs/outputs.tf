output "aws_ecs_service_arn" {
  value = aws_ecs_service.this.id
}

output "alb_url" {
  value = "http://${aws_alb.this.dns_name}"
}
