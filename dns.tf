# Hosted Zone
resource "aws_route53_zone" "hz_main" {
  name = var.hz_main_name
}

resource "aws_route53_record" "hz_main_record_ns" {
  name = var.hz_main_name
  records = [
    "ns-1266.awsdns-30.org.",
    "ns-130.awsdns-16.com.",
    "ns-2005.awsdns-58.co.uk.",
    "ns-654.awsdns-17.net.",
  ]
  ttl     = 172800
  type    = "NS"
  zone_id = aws_route53_zone.hz_main.zone_id
}

resource "aws_route53_record" "hz_main_record_soa" {
  name = var.hz_main_name
  records = [
    "ns-2005.awsdns-58.co.uk. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400",
  ]
  ttl     = 900
  type    = "SOA"
  zone_id = aws_route53_zone.hz_main.zone_id
}

# ACM
resource "aws_acm_certificate" "hz_main_cert" {
  domain_name               = var.hz_main_name
  subject_alternative_names = [format("*.%s", var.hz_main_name)]
  validation_method         = "DNS"
}

## ACM Validation Record
resource "aws_route53_record" "hz_main_record_certverify" {
  for_each = {
    for dvo in aws_acm_certificate.hz_main_cert.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = aws_route53_zone.hz_main.zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

resource "aws_acm_certificate_validation" "hz_main_cert_validate" {
  certificate_arn         = aws_acm_certificate.hz_main_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.hz_main_record_certverify : record.fqdn]
}

## ALB Alias Record
resource "aws_route53_record" "hz_main_record_alb" {
  zone_id = aws_route53_zone.hz_main.zone_id
  name    = format("elon-kiosk.%s", var.hz_main_name)
  type    = "A"

  alias {
    name                   = aws_alb.alb_main.dns_name
    zone_id                = aws_alb.alb_main.zone_id
    evaluate_target_health = true
  }
}
