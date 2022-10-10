# ----- Keypair -----
resource "aws_key_pair" "ec2_ssh_pub" {
  key_name   = "elon-kiosk-ssh-pubkey"
  public_key = file("./ec2-ssh.pub")
}

# ----- AMI -----
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

# ----- SG -----
resource "aws_security_group" "sg_apiserver" {
  name = "elon-kiosk-api-sg"

  vpc_id = aws_vpc.vpc_main.id
  ingress = [{
    description      = "API Access"
    cidr_blocks      = ["0.0.0.0/0"]
    security_groups  = null
    from_port        = 8080
    ipv6_cidr_blocks = null
    prefix_list_ids  = null
    protocol         = "tcp"
    self             = false
    to_port          = 8080
    }, {
    description      = "SSH Access"
    cidr_blocks      = ["0.0.0.0/0"]
    security_groups  = null
    from_port        = 22
    ipv6_cidr_blocks = null
    prefix_list_ids  = null
    protocol         = "tcp"
    self             = false
    to_port          = 22
  }]

  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = null
    from_port        = 0
    ipv6_cidr_blocks = null
    prefix_list_ids  = null
    protocol         = "-1"
    security_groups  = null
    self             = false
    to_port          = 0
  }]
}

# ----- EC2 -----
resource "aws_instance" "apiserver" {
  ami           = data.aws_ami.amazonLinux.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [
    aws_security_group.sg_apiserver.id
  ]

  subnet_id = aws_subnet.vpc_main_priv_subnet_api.id
  key_name  = "elon-kiosk-ssh-pubkey"

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    tags = {
      Name = "elon-kiosk-api-ec2volume"
    }
  }

  tags = {
    Name = "elon-kiosk-api"
  }
}

# WARNING
# This instance is intended to use as a SSH tunnel to the API server instance
# Should be deleted in production environment
resource "aws_instance" "tunnel" {
  ami           = data.aws_ami.amazonLinux.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [
    aws_security_group.sg_apiserver.id
  ]

  subnet_id = aws_subnet.vpc_main_pub_subnet.id
  key_name  = "elon-kiosk-ssh-pubkey"

  tags = {
    Name = "elon-kiosk-tunnel"
  }

  associate_public_ip_address = true
}
