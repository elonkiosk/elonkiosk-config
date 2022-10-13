# Webview bucket
## Customer
resource "aws_s3_bucket" "wv_customer_bucket" {
  bucket = "elon-kiosk-webview-customer-bucket"
}

### Bucket ACL setting
resource "aws_s3_bucket_acl" "wv_customer_bucket_acl" {
  bucket = aws_s3_bucket.wv_customer_bucket.id
  acl    = "private"
}

data "aws_iam_policy_document" "wv_customer_bucket_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.wv_customer_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.fe_customer_oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "wv_customer_bucket_policy" {
  bucket = aws_s3_bucket.wv_customer_bucket.id
  policy = data.aws_iam_policy_document.wv_customer_bucket_policy.json
}

## Store
resource "aws_s3_bucket" "wv_store_bucket" {
  bucket = "elon-kiosk-webview-store-bucket"
}

### Bucket ACL setting
resource "aws_s3_bucket_acl" "wv_store_bucket_acl" {
  bucket = aws_s3_bucket.wv_store_bucket.id
  acl    = "private"
}

data "aws_iam_policy_document" "wv_store_bucket_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.wv_store_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.fe_store_oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "wv_store_bucket_policy" {
  bucket = aws_s3_bucket.wv_store_bucket.id
  policy = data.aws_iam_policy_document.wv_store_bucket_policy.json
}

# Menu image bucket
resource "aws_s3_bucket" "menu_img_bucket" {
  bucket = "elon-kiosk-menu-img-bucket"
}

resource "aws_s3_bucket" "be_bucket" {
  bucket = "elon-kiosk-backend-bucket"
}
