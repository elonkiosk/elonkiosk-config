# ----- VPC -----
resource "aws_vpc" "vpc_main" {
  cidr_block       = "172.16.0.0/16"

  tags = {
    Name = "elon-kiosk-vpc-main"
  }
}
