# RDS Database Instance configuration
resource "aws_db_instance" "primary_rds_instance" {
  identifier              = var.instance_identifier         # Unique DB instance identifier
  db_name                 = var.db_name                    # Initial database name
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  allocated_storage       = var.allocated_storage          # Storage size in GB
  storage_type            = var.storage_type               # Type of storage (e.g., gp3)
  engine                  = var.engine                     # Database engine (e.g., postgres)
  engine_version          = var.engine_version             # Engine version
  instance_class          = var.instance_class             # Instance type (e.g., db.t3.medium)
  multi_az                = true                          # Enable Multi-AZ for high availability
  username                = local.db_credentials.username  # DB username from Secrets Manager
  password                = local.db_credentials.password  # DB password from Secrets Manager
  port                    = var.port                       # DB port (default 5432 for Postgres)
  vpc_security_group_ids  = [aws_security_group.database_sg.id] # Attach security group
  publicly_accessible     = var.publicly_accessible        # Control public access
  backup_retention_period = var.backup_retention_period    # Backup retention in days
  skip_final_snapshot     = true                           # Skip final snapshot on deletion

  lifecycle {
    ignore_changes = [
      password,  # Ignore password changes to avoid unwanted replacement of DB
    ]
  }
}

# Subnet group for the RDS instance to specify which subnets the DB will reside in
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = var.db_subnet_group_name
  subnet_ids = [var.private_db_subnet_a_id, var.private_db_subnet_b_id]
}

# Security group to control access to the database
resource "aws_security_group" "database_sg" {
  name        = "database_sg"
  description = "Security group for the database"
  vpc_id      = var.main_vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.backend_app_sg_id]  # Allow inbound traffic from backend app SG only
    description     = "Allow traffic from backend application server"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]                # Allow all outbound traffic
    description = "Allow all outbound traffic"
  }
}

# Fetch existing database credentials from AWS Secrets Manager
data "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = "arn:aws:secretsmanager:us-east-1:415730361496:secret:rds/iam-policy-generator-credentials-SaJs7B"
}

# Create a new Secrets Manager secret to store updated DB credentials and connection info
resource "aws_secretsmanager_secret" "db_credentials_output" {
  name                    = "rds/iam-policy-generator-credentials-output"
  description             = "Database credentials for IAM Policy Generator"
  recovery_window_in_days = 0  # No recovery window to allow immediate deletion if needed
}

# Store current DB credentials and connection info in Secrets Manager
resource "aws_secretsmanager_secret_version" "db_credentials_output_value" {
  secret_id     = aws_secretsmanager_secret.db_credentials_output.id
  secret_string = jsonencode({
    username = local.db_credentials.username
    password = local.db_credentials.password
    host     = aws_db_instance.primary_rds_instance.address
    port     = aws_db_instance.primary_rds_instance.port
    db_name  = aws_db_instance.primary_rds_instance.db_name
  })
}

# Local variable to decode existing DB credentials secret string
locals {
  db_credentials = jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string)
}
