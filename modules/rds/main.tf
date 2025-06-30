resource "aws_db_subnet_group" "lamp" {
  name       = "lamp-db-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = "lamp-db-subnet-group"
  }
}

resource "aws_db_instance" "lamp" {
  identifier              = "lamp-db"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp2"
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.lamp.name
  vpc_security_group_ids  = [var.db_sg_id]
  publicly_accessible     = false
  skip_final_snapshot     = true
  deletion_protection     = false
  multi_az                = false

  tags = {
    Name = "lamp-rds-instance"
  }
}
