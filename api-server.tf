# Keypair
resource "aws_key_pair" "ec2_ssh_pub" {
  key_name   = "elon-kiosk-ssh-pubkey"
  public_key = file("./ec2-ssh.pub")
}

# AMI
data "aws_ami" "amazonLinux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# SG
resource "aws_security_group" "sg_apiserver" {
  name = "elon-kiosk-api-sg"
  description = "API Server Security Group"
  vpc_id = aws_vpc.vpc_main.id

  tags = {
    Name = "elon-kiosk-api-sg"
  }
}

## SG Rules
### Ingress
resource "aws_security_group_rule" "sg_apiserver_rule_ing_http" {
  type              = "ingress"
  from_port         = var.apiserver_port
  to_port           = var.apiserver_port
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_apiserver.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "sg_apiserver_rule_ing_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_apiserver.id

  lifecycle {
    create_before_destroy = true
  }
}

### Egress
resource "aws_security_group_rule" "sg_apiserver_rule_eg_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_apiserver.id

  lifecycle {
    create_before_destroy = true
  }
}

# EC2
## AZ1
resource "aws_instance" "apiserver_az1" {
  ami           = data.aws_ami.amazonLinux.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [
    aws_security_group.sg_apiserver.id
  ]

  subnet_id = aws_subnet.priv_subnet_az1_api.id
  key_name  = "elon-kiosk-ssh-pubkey"

  tags = {
    Name = "elon-kiosk-api-az1"
  }
}

## AZ2
resource "aws_instance" "apiserver_az2" {
  ami           = data.aws_ami.amazonLinux.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [
    aws_security_group.sg_apiserver.id
  ]

  subnet_id = aws_subnet.priv_subnet_az2_api.id
  key_name  = "elon-kiosk-ssh-pubkey"

  tags = {
    Name = "elon-kiosk-api-az2"
  }
}

# WARNING
# This instance is intended to use as a SSH tunnel to the API server instance
# Should be deleted in production environment
resource "aws_instance" "tunnel" {
  ami           = data.aws_ami.amazonLinux.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.pub_subnet_az1.id
  key_name  = "elon-kiosk-ssh-pubkey"
  associate_public_ip_address = true

  tags = {
    Name = "elon-kiosk-tunnel"
  }
}
