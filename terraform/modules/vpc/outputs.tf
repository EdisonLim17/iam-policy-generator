output "main_vpc_id" {
  description = "The ID of the main VPC"
  value       = aws_vpc.main_vpc.id
}

output "public_web_subnet_a_id" {
  description = "The ID of the public web subnet A"
  value       = aws_subnet.public_web_subnet_a.id
}

output "public_web_subnet_b_id" {
  description = "The ID of the public web subnet B"
  value       = aws_subnet.public_web_subnet_b.id
}

output "private_app_subnet_a_id" {
  description = "The ID of the private app subnet A"
  value       = aws_subnet.private_app_subnet_a.id
}

output "private_app_subnet_b_id" {
  description = "The ID of the private app subnet B"
  value       = aws_subnet.private_app_subnet_b.id
}

output "private_db_subnet_a_id" {
  description = "The ID of the private DB subnet A"
  value       = aws_subnet.private_db_subnet_a.id
}

output "private_db_subnet_b_id" {
  description = "The ID of the private DB subnet B"
  value       = aws_subnet.private_db_subnet_b.id
}