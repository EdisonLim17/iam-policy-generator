# Get the existing hosted zone from the general account
data "aws_route53_zone" "root_domain" {
    provider = aws.general_account

    name         = var.root_domain_name
}

# Backend ACM certificate in production account
resource "aws_acm_certificate" "iam_policy_generator_backend_cert" {
    domain_name       = var.iam_policy_generator_backend_subdomain_name
    validation_method = "DNS"

    lifecycle {
        create_before_destroy = true
    }
}

# DNS record in general account to validate backend ACM certificate
resource "aws_route53_record" "iam_policy_generator_backend_cert_validation" {
    provider = aws.general_account

    zone_id = data.aws_route53_zone.root_domain.zone_id
    name    = local.backend_cert_validation_option.resource_record_name
    type    = local.backend_cert_validation_option.resource_record_type
    records = [local.backend_cert_validation_option.resource_record_value]
    ttl     = 300
}

# Final validation of the backend ACM certificate
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

# Frontend ACM certificate in production account
resource "aws_acm_certificate" "iam_policy_generator_frontend_cert" {
    domain_name       = var.iam_policy_generator_frontend_subdomain_name
    validation_method = "DNS"

    lifecycle {
        create_before_destroy = true
    }
}

# DNS record in general account to validate frontend ACM certificate
resource "aws_route53_record" "iam_policy_generator_frontend_cert_validation" {
    provider = aws.general_account

    zone_id = data.aws_route53_zone.root_domain.zone_id
    name    = local.frontend_cert_validation_option.resource_record_name
    type    = local.frontend_cert_validation_option.resource_record_type
    records = [local.frontend_cert_validation_option.resource_record_value]
    ttl     = 300
}

# Final validation of the frontend ACM certificate
resource "aws_acm_certificate_validation" "iam_policy_generator_frontend_cert_validation" {
    certificate_arn         = aws_acm_certificate.iam_policy_generator_frontend_cert.arn
    validation_record_fqdns = [aws_route53_record.iam_policy_generator_frontend_cert_validation.fqdn]
}

resource "aws_amplify_domain_association" "custom_amplify_domain" {
    app_id = var.amplify_app_id
    domain_name = var.iam_policy_generator_frontend_subdomain_name

    sub_domain {
        branch_name = var.amplify_branch_name
        prefix      = ""
    }

    depends_on = [ aws_acm_certificate_validation.iam_policy_generator_frontend_cert_validation ]
}

resource "aws_route53_record" "amplify_domain_verification" {
    provider = aws.general_account

    zone_id = data.aws_route53_zone.root_domain.zone_id
    # No hard-coded values here but is impossible since amplify_domain_association won't finish creating before the DNS records are created
    name    = split(" ", aws_amplify_domain_association.custom_amplify_domain.certificate_verification_dns_record)[0]
    type    = split(" ", aws_amplify_domain_association.custom_amplify_domain.certificate_verification_dns_record)[1]
    records = [split(" ", aws_amplify_domain_association.custom_amplify_domain.certificate_verification_dns_record)[2]]
    # these values are manually added after terraform apply by fetching from amplify console
    # name    = "_e8d2db6045bed74144ffd93eb0df8f8e.iampolicygenerator.edisonlim.ca."
    # type    = "CNAME"
    # records = ["_80565fae2baef7faf98738dc38de4385.xlfgrmvvlj.acm-validations.aws."]
    ttl = 300
}

resource "aws_route53_record" "amplify_cname" {
    provider = aws.general_account

    zone_id = data.aws_route53_zone.root_domain.zone_id
    name    = var.iam_policy_generator_frontend_subdomain_name
    # No hard-coded values here but is impossible since amplify_domain_association won't finish creating before the DNS records are created
    type    = split(" ", local.amplify_subdomain_records[0])[0]
    records = [split(" ", local.amplify_subdomain_records[0])[1]]
    # these values are manually added after terraform apply by fetching from amplify console
    # type    = "CNAME"
    # records = ["d36ilisttnd6un.cloudfront.net"]
    ttl     = 300
}

locals {
  backend_cert_validation_option = element(tolist(aws_acm_certificate.iam_policy_generator_backend_cert.domain_validation_options), 0)
  frontend_cert_validation_option = element(tolist(aws_acm_certificate.iam_policy_generator_frontend_cert.domain_validation_options), 0)

  amplify_subdomain_records = [for sd in aws_amplify_domain_association.custom_amplify_domain.sub_domain : sd.dns_record]
}