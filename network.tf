# VPC
resource "aws_vpc" "vpc_main" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "elon-kiosk-vpc-main"
  }
}

# Gateways
## IGW
resource "aws_internet_gateway" "igw_main" {
  vpc_id = aws_vpc.vpc_main.id

  tags = {
    Name = "elon-kiosk-igw"
  }
}

## NAT Gateway
resource "aws_eip" "eip_nat" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "nat_main" {
  allocation_id = aws_eip.eip_nat.id

  subnet_id = aws_subnet.pub_subnet_az1.id

  tags = {
    Name = "elon-kiosk-nat"
  }
}

# Public Subnet
## Route Table
resource "aws_route_table" "pub_rtb" {
  vpc_id = aws_vpc.vpc_main.id

  tags = {
    Name = "elon-kiosk-public-rtb"
  }
}

resource "aws_route" "pub_rtb_default" {
  route_table_id         = aws_route_table.pub_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_main.id
}

## Subnet - AZ1
resource "aws_subnet" "pub_subnet_az1" {
  vpc_id     = aws_vpc.vpc_main.id
  cidr_block = "172.16.1.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "elon-kiosk-public-subnet-az1"
  }
}

resource "aws_route_table_association" "pub_subnet_az1_rtb_assoc" {
  subnet_id      = aws_subnet.pub_subnet_az1.id
  route_table_id = aws_route_table.pub_rtb.id
}

## Subnet - AZ2
resource "aws_subnet" "pub_subnet_az2" {
  vpc_id     = aws_vpc.vpc_main.id
  cidr_block = "172.16.4.0/24"

  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "elon-kiosk-public-subnet-az2"
  }
}

resource "aws_route_table_association" "pub_subnet_az2_rtb_assoc" {
  subnet_id      = aws_subnet.pub_subnet_az2.id
  route_table_id = aws_route_table.pub_rtb.id
}

# Private Subnet
## Route Table
resource "aws_route_table" "priv_rtb" {
  vpc_id = aws_vpc.vpc_main.id

  tags = {
    Name = "elon-kiosk-private-rtb"
  }
}

resource "aws_route" "priv_rtb_default" {
  route_table_id         = aws_route_table.priv_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_main.id
}

## API Layer (AZ1)
resource "aws_subnet" "priv_subnet_az1_api" {
  vpc_id     = aws_vpc.vpc_main.id
  cidr_block = "172.16.2.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "elon-kiosk-private-subnet-az1-api"
  }
}

resource "aws_route_table_association" "priv_subnet_az1_api_rtb_assoc" {
  subnet_id      = aws_subnet.priv_subnet_az1_api.id
  route_table_id = aws_route_table.priv_rtb.id
}

## API Layer (AZ2)
resource "aws_subnet" "priv_subnet_az2_api" {
  vpc_id     = aws_vpc.vpc_main.id
  cidr_block = "172.16.5.0/24"

  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "elon-kiosk-private-subnet-az2-api"
  }
}

resource "aws_route_table_association" "priv_subnet_az2_api_rtb_assoc" {
  subnet_id      = aws_subnet.priv_subnet_az2_api.id
  route_table_id = aws_route_table.priv_rtb.id
}

## DB Layer (AZ1)
resource "aws_subnet" "priv_subnet_az1_db" {
  vpc_id     = aws_vpc.vpc_main.id
  cidr_block = "172.16.3.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "elon-kiosk-private-subnet-az1-db"
  }
}

resource "aws_route_table_association" "priv_subnet_az1_db_rtb_assoc" {
  subnet_id      = aws_subnet.priv_subnet_az1_db.id
  route_table_id = aws_route_table.priv_rtb.id
}

## DB Layer (AZ2)
resource "aws_subnet" "priv_subnet_az2_db" {
  vpc_id     = aws_vpc.vpc_main.id
  cidr_block = "172.16.6.0/24"

  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "elon-kiosk-private-subnet-az2-db"
  }
}

resource "aws_route_table_association" "priv_subnet_az2_db_rtb_assoc" {
  subnet_id      = aws_subnet.priv_subnet_az2_db.id
  route_table_id = aws_route_table.priv_rtb.id
}
