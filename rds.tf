resource "aws_security_group" "rds" {
  name        = "mmotors-rds-sg"
  description = "RDS PostgreSQL"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description     = "PostgreSQL depuis ECS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "mmotors-db-subnets"
  subnet_ids = data.aws_subnets.default.ids
}

resource "aws_db_instance" "postgres" {
  identifier     = "mmotors-postgres"
  engine         = "postgres"
  engine_version = "16"
  instance_class = "db.t3.micro"

  db_name  = "mmotors"
  username = var.db_username
  password = var.db_password

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false

  backup_retention_period = 1

  skip_final_snapshot = true
}
