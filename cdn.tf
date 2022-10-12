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
## OAIs
resource "aws_cloudfront_origin_access_identity" "fe_customer_oai" {
}

resource "aws_cloudfront_origin_access_identity" "fe_store_oai" {
}

resource "aws_cloudfront_distribution" "fe_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
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

  # S3 Origin: customer webview bucket
  origin {
    domain_name = aws_s3_bucket.wv_customer_bucket.bucket_domain_name
    origin_id   = aws_s3_bucket.wv_customer_bucket.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.fe_customer_oai.cloudfront_access_identity_path
    }
  }

  # S3 Origin: store webview bucket
  origin {
    domain_name = aws_s3_bucket.wv_store_bucket.bucket_domain_name
    origin_id   = aws_s3_bucket.wv_store_bucket.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.fe_store_oai.cloudfront_access_identity_path
    }
  }

  # ALB origin
  origin {
    domain_name = aws_alb.alb_main.dns_name
    origin_id   = aws_alb.alb_main.id

    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols = ["TLSv1.2"]
    }
  }

  # ALB behavior (precedence 0)
  ordered_cache_behavior {
    path_pattern     = "/api*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_alb.alb_main.id

    forwarded_values {
      query_string = true # Forward all query_string
      headers = ["*"] # Forward all headers

      cookies {
        forward = "all" # Forward all cookies
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    viewer_protocol_policy = "redirect-to-https"
  }

  # S3:store behavior (precedence default)
  ordered_cache_behavior {
    path_pattern     = "/store*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.wv_store_bucket.id

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

  # S3:customer behavior (default precedence)
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.wv_customer_bucket.id

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
}
