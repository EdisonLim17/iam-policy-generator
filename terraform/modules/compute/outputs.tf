output "fastapi_backend_app_server_sg_id" {
  description = "The ID of the security group for the FastAPI backend app server"
  value       = aws_security_group.fastapi_backend_app_server_sg.id
}
