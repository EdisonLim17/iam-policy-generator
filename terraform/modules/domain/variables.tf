variable "root_domain_name" {
    description = "Name of the root domain"
    type        = string
    default     = "edisonlim.ca"
}

variable "iam_policy_generator_backend_subdomain_name" {
    description = "Subdomain name for the IAM Policy Generator backend"
    type        = string
    default     = "iampolicygenerator-backend.edisonlim.ca"
}

variable "iam_policy_generator_frontend_subdomain_name" {
    description = "Subdomain name for the IAM Policy Generator frontend"
    type        = string
    default     = "iampolicygenerator.edisonlim.ca"
}

variable "alb_dns_name" {
    description = "DNS name of the Application Load Balancer"
    type        = string
    default = ""
}

variable "alb_zone_id" {
    description = "Zone ID of the Application Load Balancer"
    type        = string
    default = ""
}

variable "amplify_app_id" {
    description = "ID of the Amplify app"
    type        = string
    default     = ""
}

variable "amplify_branch_name" {
    description = "Name of the Amplify branch"
    type        = string
    default     = "main"
}

variable "amplify_default_domain" {
    description = "Default domain of the Amplify app"
    type        = string
    default     = ""
}