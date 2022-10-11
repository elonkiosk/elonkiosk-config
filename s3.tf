# Webview bucket
resource "aws_s3_bucket" "webview_bucket" {
  bucket = "elon-kiosk-webview-bucket"
}

## Bucket ACL setting
resource "aws_s3_bucket_acl" "webview_bucket_acl" {
  bucket = aws_s3_bucket.webview_bucket.id
  acl = "private"
}

data "aws_iam_policy_document" "webview_bucket_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.webview_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.fe_oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "webview_bucket_policy" {
  bucket = aws_s3_bucket.webview_bucket.id
  policy = data.aws_iam_policy_document.webview_bucket_policy.json
}

# Menu image bucket
resource "aws_s3_bucket" "menu_img_bucket" {
  bucket = "elon-kiosk-menu-img-bucket"
}
