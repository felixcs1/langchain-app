# Pricing:

# 1) You incur charges for every DNS query answered by the Amazon Route 53 service,
# except for queries to Alias A records that are mapped to Elastic Load Balancing instances

# 2) You pay $0.50 per hosted zone / month for the first 25 hosted zones

# 3) $0.40 per million queries – first 1 Billion queries / month

# 4) No additional cost for using alias records

# N.B this was registered in namecheap
# and moved to this aws zone created outside of terraform
data "aws_route53_zone" "selected" {
  name = "felixcs.xyz"
}


resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "api.${data.aws_route53_zone.selected.name}"
  type    = "A"

  alias {
    name                   = aws_alb.this.dns_name
    zone_id                = aws_alb.this.zone_id
    evaluate_target_health = false # costs extra
  }
}
