# Get the existing Route53 hosted zone from the general AWS account
data "aws_route53_zone" "root_domain" {
  provider = aws.general_account
  name     = var.root_domain_name
}

# Backend ACM certificate request in production account, validated via DNS
resource "aws_acm_certificate" "iam_policy_generator_backend_cert" {
  domain_name       = var.iam_policy_generator_backend_subdomain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true  # Prevent downtime during updates
  }
}

# DNS record in general account to validate backend ACM certificate via DNS validation
resource "aws_route53_record" "iam_policy_generator_backend_cert_validation" {
  provider = aws.general_account

  zone_id = data.aws_route53_zone.root_domain.zone_id
  name    = local.backend_cert_validation_option.resource_record_name
  type    = local.backend_cert_validation_option.resource_record_type
  records = [local.backend_cert_validation_option.resource_record_value]
  ttl     = 300
}

# Complete ACM certificate validation for backend certificate using the DNS record
resource "aws_acm_certificate_validation" "iam_policy_generator_backend_cert_validation" {
  certificate_arn          = aws_acm_certificate.iam_policy_generator_backend_cert.arn
  validation_record_fqdns  = [aws_route53_record.iam_policy_generator_backend_cert_validation.fqdn]
}

# Route53 Alias record pointing backend subdomain to ALB DNS (in general account)
resource "aws_route53_record" "alb_alias" {
  provider = aws.general_account

  zone_id = data.aws_route53_zone.root_domain.zone_id
  name    = var.iam_policy_generator_backend_subdomain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

# Frontend ACM certificate request in production account, validated via DNS
resource "aws_acm_certificate" "iam_policy_generator_frontend_cert" {
  domain_name       = var.iam_policy_generator_frontend_subdomain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# DNS record in general account to validate frontend ACM certificate via DNS validation
resource "aws_route53_record" "iam_policy_generator_frontend_cert_validation" {
  provider = aws.general_account

  zone_id = data.aws_route53_zone.root_domain.zone_id
  name    = local.frontend_cert_validation_option.resource_record_name
  type    = local.frontend_cert_validation_option.resource_record_type
  records = [local.frontend_cert_validation_option.resource_record_value]
  ttl     = 300
}

# Complete ACM certificate validation for frontend certificate using the DNS record
resource "aws_acm_certificate_validation" "iam_policy_generator_frontend_cert_validation" {
  certificate_arn          = aws_acm_certificate.iam_policy_generator_frontend_cert.arn
  validation_record_fqdns  = [aws_route53_record.iam_policy_generator_frontend_cert_validation.fqdn]
}

# Associate the custom domain with Amplify frontend app and link the branch
resource "aws_amplify_domain_association" "custom_amplify_domain" {
  app_id      = var.amplify_app_id
  domain_name = var.iam_policy_generator_frontend_subdomain_name

  sub_domain {
    branch_name = var.amplify_branch_name
    prefix      = ""  # Root domain (no prefix)
  }

  depends_on = [aws_acm_certificate_validation.iam_policy_generator_frontend_cert_validation]
}

# NOTE: The following commented-out resources for Amplify domain verification and CNAME
# records require manual creation after Terraform apply due to dependency/order limitations.
# This avoids having to run Terraform apply twice.

# resource "aws_route53_record" "amplify_domain_verification" {
#   provider = aws.general_account
#   zone_id  = data.aws_route53_zone.root_domain.zone_id
#   name     = split(" ", aws_amplify_domain_association.custom_amplify_domain.certificate_verification_dns_record)[0]
#   type     = "CNAME"
#   records  = [split(" ", aws_amplify_domain_association.custom_amplify_domain.certificate_verification_dns_record)[2]]
#   ttl      = 300
# }

# resource "aws_route53_record" "amplify_cname" {
#   provider = aws.general_account
#   zone_id  = data.aws_route53_zone.root_domain.zone_id
#   name     = var.iam_policy_generator_frontend_subdomain_name
#   type     = "CNAME"
#   records  = [split(" ", local.amplify_subdomain_records[0])[1]]
#   ttl      = 300
# }

# Local values to extract validation options from ACM certificates and Amplify subdomain DNS records
locals {
  backend_cert_validation_option  = element(tolist(aws_acm_certificate.iam_policy_generator_backend_cert.domain_validation_options), 0)
  frontend_cert_validation_option = element(tolist(aws_acm_certificate.iam_policy_generator_frontend_cert.domain_validation_options), 0)

  amplify_subdomain_records = [for sd in aws_amplify_domain_association.custom_amplify_domain.sub_domain : sd.dns_record]
}
