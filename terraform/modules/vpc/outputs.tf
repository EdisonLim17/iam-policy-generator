# ------------------------------------------------------------------------------
# VPC Outputs
# ------------------------------------------------------------------------------

output "main_vpc_id" {
  description = "The ID of the main VPC."
  value       = aws_vpc.main_vpc.id
}

# ------------------------------------------------------------------------------
# Public Subnet Outputs (for ALB, NAT Gateway, etc.)
# ------------------------------------------------------------------------------

output "public_web_subnet_a_id" {
  description = "The ID of the public web subnet in AZ A."
  value       = aws_subnet.public_web_subnet_a.id
}

output "public_web_subnet_b_id" {
  description = "The ID of the public web subnet in AZ B."
  value       = aws_subnet.public_web_subnet_b.id
}

# ------------------------------------------------------------------------------
# Private Subnet Outputs (for FastAPI backend EC2 instances)
# ------------------------------------------------------------------------------

output "private_app_subnet_a_id" {
  description = "The ID of the private app subnet in AZ A."
  value       = aws_subnet.private_app_subnet_a.id
}

output "private_app_subnet_b_id" {
  description = "The ID of the private app subnet in AZ B."
  value       = aws_subnet.private_app_subnet_b.id
}

# ------------------------------------------------------------------------------
# Private Subnet Outputs (for RDS database)
# ------------------------------------------------------------------------------

output "private_db_subnet_a_id" {
  description = "The ID of the private database subnet in AZ A."
  value       = aws_subnet.private_db_subnet_a.id
}

output "private_db_subnet_b_id" {
  description = "The ID of the private database subnet in AZ B."
  value       = aws_subnet.private_db_subnet_b.id
}
