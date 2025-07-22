output "alb_sg_id" {
  description = "The ID of the security group for the ALB"
  value       = aws_security_group.alb_sg.id
}

output "fastapi_backend_app_server_tg_arn" {
  description = "The ARN of the FastAPI backend application server target group"
  value       = aws_lb_target_group.fastapi_backend_app_server_tg.arn
}