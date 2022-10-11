# Global Certificate
resource "aws_acm_certificate" "global_cert" {
  provider                  = aws.virginia
  domain_name               = var.hz_main_name
  subject_alternative_names = [format("*.%s", var.hz_main_name)]
  validation_method         = "DNS"
}

## ACM Validation
resource "aws_acm_certificate_validation" "global_cert_validate" {
  provider                = aws.virginia
  certificate_arn         = aws_acm_certificate.global_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.hz_main_record_certverify : record.fqdn]
}

# CloudFront Distribution
resource "aws_cloudfront_origin_access_identity" "fe_oai" {
}

resource "aws_cloudfront_distribution" "fe_distribution" {
  origin {
    domain_name = aws_s3_bucket.webview_bucket.bucket_domain_name
    origin_id   = aws_s3_bucket.webview_bucket.id
    origin_path = "/customer"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.fe_oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.webview_bucket.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.global_cert.arn
    ssl_support_method  = "sni-only"
  }
}
