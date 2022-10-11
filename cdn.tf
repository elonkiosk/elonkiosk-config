resource "aws_cloudfront_origin_access_identity" "webview_distribution_oai" {
}

resource "aws_cloudfront_distribution" "webview_distribution" {
  origin {
    domain_name = aws_s3_bucket.webview_bucket.bucket_domain_name
    origin_id   = aws_s3_bucket.webview_bucket.id
    origin_path = "/customer"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.webview_distribution_oai.cloudfront_access_identity_path
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
    # acm_certificate_arn = aws_acm_certificate.hz_main_cert.arn
    cloudfront_default_certificate = true
  }
}
