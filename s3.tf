resource "aws_s3_bucket" "webview_bucket" {
  bucket = "elon-kiosk-webview-bucket"
}

resource "aws_s3_bucket" "menu_img_bucket" {
  bucket = "elon-kiosk-menu-img-bucket"
}
