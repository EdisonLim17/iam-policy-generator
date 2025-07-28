resource "aws_db_instance" "primary_rds_instance" {
  identifier              = var.instance_identifier
  db_name                = var.db_name
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  allocated_storage       = var.allocated_storage
  storage_type            = var.storage_type
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  multi_az = true
  username               = local.db_credentials.username
  password               = local.db_credentials.password
  port                   = var.port
  vpc_security_group_ids = [aws_security_group.database_sg.id]
  publicly_accessible    = var.publicly_accessible
  backup_retention_period = var.backup_retention_period
  skip_final_snapshot = true

  lifecycle {
    ignore_changes = [
      password, # Ignore changes to password to avoid unnecessary recreation
    ]
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = var.db_subnet_group_name
  subnet_ids = [var.private_db_subnet_a_id, var.private_db_subnet_b_id]
}

resource "aws_security_group" "database_sg" {
    name        = "database_sg"
    description = "Security group for the database"
    vpc_id      = var.main_vpc_id

    ingress {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        security_groups = [var.backend_app_sg_id]
        description = "Allow traffic from backend application server"
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow all outbound traffic"
    }
}

data "aws_secretsmanager_secret_version" "db_password" {
    secret_id     = "arn:aws:secretsmanager:us-east-1:415730361496:secret:rds/iam-policy-generator-credentials-SaJs7B"
}

locals {
  db_credentials = jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string)
}