# SG
resource "aws_security_group" "sg_admin" {
  name        = "elon-kiosk-admin-sg"
  description = "Admin EC2 Security Group"
  vpc_id      = aws_vpc.vpc_main.id

  tags = {
    Name = "elon-kiosk-admin-sg"
  }
}

## SG Rules
### Ingress
resource "aws_security_group_rule" "sg_admin_rule_ing_test_port" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_admin.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "sg_admin_rule_ing_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_admin.id

  lifecycle {
    create_before_destroy = true
  }
}

### Egress
resource "aws_security_group_rule" "sg_admin_rule_eg_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_admin.id

  lifecycle {
    create_before_destroy = true
  }
}

# WARNING
# This instance is intended to use as a SSH tunnel to the API server instance
# Should be deleted in production environment
resource "aws_instance" "admin" {
  ami                         = data.aws_ami.amazonLinux.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.pub_subnet_az1.id
  key_name                    = "elon-kiosk-ssh-pubkey"
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.sg_admin.id
  ]

  tags = {
    Name = "elon-kiosk-admin"
  }
}
