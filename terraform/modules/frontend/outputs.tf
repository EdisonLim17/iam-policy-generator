output "amplify_app_url" {
  description = "The URL of the Amplify frontend application"
  value       = aws_amplify_app.frontend_web.default_domain
}