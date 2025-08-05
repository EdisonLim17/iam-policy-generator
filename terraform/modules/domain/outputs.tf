output "iam_policy_generator_backend_cert_arn" {
  description = "The ARN of the ACM certificate for the IAM Policy Generator backend"
  value       = aws_acm_certificate.iam_policy_generator_backend_cert.arn
}
