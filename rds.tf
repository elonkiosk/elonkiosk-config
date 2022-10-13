# SG
resource "aws_security_group" "sg_db" {
  name        = "elon-kiosk-db-sg"
  description = "DB Security Group"
  vpc_id      = aws_vpc.vpc_main.id

  tags = {
    Name = "elon-kiosk-db-sg"
  }
}

## SG Rules
### Ingress
resource "aws_security_group_rule" "sg_db_rule_ing_conn" {
  type                     = "ingress"
  from_port                = var.DB_PORT
  to_port                  = var.DB_PORT
  protocol                 = "TCP"
  source_security_group_id = aws_security_group.sg_apiserver.id
  security_group_id        = aws_security_group.sg_db.id

  lifecycle {
    create_before_destroy = true
  }
}

### Egress
resource "aws_security_group_rule" "sg_db_rule_eg_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_db.id

  lifecycle {
    create_before_destroy = true
  }
}

# Subnet group
resource "aws_db_subnet_group" "subnet_group_db" {
  name = "elon-kiosk-subnet-group-db"
  subnet_ids = [
    aws_subnet.priv_subnet_az1_db.id,
    aws_subnet.priv_subnet_az2_db.id
  ]

  tags = {
    Name = "elon-kiosk-subnet-group-db"
  }
}

# RDS instance
resource "aws_db_instance" "db_main" {
  allocated_storage      = 20
  max_allocated_storage  = 50
  availability_zone      = "ap-northeast-2a"
  db_subnet_group_name   = aws_db_subnet_group.subnet_group_db.name
  engine                 = "mysql"
  engine_version         = "8.0.30"
  instance_class         = "db.t3.micro"
  skip_final_snapshot    = true
  identifier             = "elon-kiosk-db"
  username               = var.DB_USERNAME
  password               = var.DB_PASSWORD
  db_name                = var.DB_NAME
  port                   = var.DB_PORT
  vpc_security_group_ids = [aws_security_group.sg_db.id]
}
