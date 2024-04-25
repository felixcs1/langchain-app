# Add a record to direct a subdomain to a specific load balancer
resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "api.${data.aws_route53_zone.selected.name}"
  type    = "A"

  # TTL for all alias records is 60 seconds, you cannot change this,
  # therefore ttl has to be omitted in alias records.
  # ttl     = "3000"
  alias {
    name                   = aws_alb.this.dns_name
    zone_id                = aws_alb.this.zone_id
    evaluate_target_health = false # costs extra
  }
}
