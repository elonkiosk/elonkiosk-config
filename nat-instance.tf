# ----- NAT Gateway (API Layer) -----
resource "aws_instance" "nat_ec2_api" {
  ami                    = "ami-05ec7a911616f7899"
  instance_type          = "t2.micro"
  availability_zone      = "ap-northeast-2a"
  subnet_id              = aws_subnet.vpc_main_pub_subnet.id

  associate_public_ip_address = true
  source_dest_check = false

  tags = {
    Name = "elon-kiosk-nat-api"
  }
}

# ----- NAT Gateway (DB Layer) -----
resource "aws_instance" "nat_ec2_db" {
  ami                    = "ami-05ec7a911616f7899"
  instance_type          = "t2.micro"
  availability_zone      = "ap-northeast-2a"
  subnet_id              = aws_subnet.vpc_main_pub_subnet.id

  associate_public_ip_address = true
  source_dest_check = false

  tags = {
    Name = "elon-kiosk-nat-db"
  }
}
