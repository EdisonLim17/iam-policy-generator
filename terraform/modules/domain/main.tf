# Get the existing hosted zone from the general account
data "aws_route53_zone" "root_domain" {
    provider = aws.general_account

    name         = var.root_domain_name
}

# ACM certificate in production account
resource "aws_acm_certificate" "iam_policy_generator_backend_cert" {
    domain_name       = var.iam_policy_generator_backend_subdomain_name
    validation_method = "DNS"

    lifecycle {
        create_before_destroy = true
    }
}

# DNS record in general account to validate ACM certificate
resource "aws_route53_record" "iam_policy_generator_backend_cert_validation" {
    provider = aws.general_account

    zone_id = data.aws_route53_zone.root_domain.zone_id
    name    = local.cert_validation_option.resource_record_name
    type    = local.cert_validation_option.resource_record_type
    ttl     = 300
    records = [local.cert_validation_option.resource_record_value]
}

# Final validation of the ACM certificate
resource "aws_acm_certificate_validation" "iam_policy_generator_backend_cert_validation" {
    certificate_arn         = aws_acm_certificate.iam_policy_generator_backend_cert.arn
    validation_record_fqdns = [aws_route53_record.iam_policy_generator_backend_cert_validation.fqdn]
}

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

locals {
  cert_validation_option = element(tolist(aws_acm_certificate.iam_policy_generator_backend_cert.domain_validation_options), 0)
}