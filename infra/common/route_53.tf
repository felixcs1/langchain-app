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

# For https
# Cert in certificate manager
resource "aws_acm_certificate" "default" {
  domain_name               = data.aws_route53_zone.selected.name
  subject_alternative_names = ["*.${data.aws_route53_zone.selected.name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = tolist(aws_acm_certificate.default.domain_validation_options)[0]["resource_record_name"]
  type    = tolist(aws_acm_certificate.default.domain_validation_options)[0]["resource_record_type"]
  records = [tolist(aws_acm_certificate.default.domain_validation_options)[0]["resource_record_value"]]
  ttl     = "300"
}

# connects our DNS record with our certificate,
# making sure AWS will be able to validate the certificate
resource "aws_acm_certificate_validation" "default" {
  certificate_arn = aws_acm_certificate.default.arn
  validation_record_fqdns = [
    "${aws_route53_record.validation.fqdn}",
  ]
}
