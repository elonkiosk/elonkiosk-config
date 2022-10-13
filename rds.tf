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

resource "aws_db_instance" "db_main" {
  allocated_storage = 20
  max_allocated_storage = 50
  availability_zone = "ap-northeast-2a"
  db_subnet_group_name = aws_db_subnet_group.subnet_group_db.name
  engine = "mysql"
  engine_version = "8.0.30"
  instance_class = "db.t3.small"
  skip_final_snapshot = true
  identifier = "elon-kiosk-db"
  username = var.DB_USERNAME
  password = var.DB_PASSWORD
  db_name = var.DB_NAME
  port = var.DB_PORT
}
