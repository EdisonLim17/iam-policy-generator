output "db_endpoint" {
  description = "The endpoint of the primary RDS instance."
  value       = aws_db_instance.primary_rds_instance.address
}

output "db_port" {
  description = "The port on which the primary RDS instance is accessible."
  value       = aws_db_instance.primary_rds_instance.port
}

output "db_name" {
  description = "The name of the primary RDS database."
  value       = var.db_name
}