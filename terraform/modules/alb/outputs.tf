output "alb_sg_id" {
  description = "The ID of the security group for the ALB"
  value       = aws_security_group.alb_sg.id
}

output "fastapi_backend_app_server_tg_arn" {
  description = "The ARN of the FastAPI backend application server target group"
  value       = aws_lb_target_group.fastapi_backend_app_server_tg.arn
}

output "fastapi_backend_app_url" {
  description = "The URL of the FastAPI backend application"
  value       = aws_lb.fastapi_backend_app_server_alb.dns_name
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.fastapi_backend_app_server_alb.dns_name
}

output "alb_zone_id" {
  description = "The zone ID of the ALB"
  value       = aws_lb.fastapi_backend_app_server_alb.zone_id
}