# Outputs for Amplify frontend app and JWT secret ARN

output "amplify_app_url" {
  description = "The URL of the Amplify frontend application"
  value       = aws_amplify_app.frontend_web.default_domain
}

output "amplify_app_id" {
  description = "The ID of the Amplify app"
  value       = aws_amplify_app.frontend_web.id
}

output "amplify_branch_name" {
  description = "The name of the Amplify branch"
  value       = aws_amplify_branch.frontend_web_branch.branch_name
}

output "amplify_default_domain" {
  description = "The default domain of the Amplify app"
  value       = aws_amplify_app.frontend_web.default_domain
}

output "jwt_secret_arn" {
  description = "The ARN of the JWT secret in AWS Secrets Manager"
  value       = aws_secretsmanager_secret.jwt_secret.arn
}