# ----- NAT Gateway (API Layer) -----
resource "aws_eip" "eip_nat" {
  vpc   = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "nat_api" {
  allocation_id = aws_eip.eip_nat.id

  subnet_id = aws_subnet.vpc_main_pub_subnet.id

  tags = {
    Name = "elon-kiosk-nat-api"
  }
}
