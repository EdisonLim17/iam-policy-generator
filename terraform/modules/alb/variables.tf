variable "fastapi_backend_app_server_lb_name" {
  description = "Name for the backend application server load balancer"
  type        = string
  default     = "fastapi-backend-app-server-lb"
}

variable "domain_name" {
  description = "Domain name for the backend application server"
  type        = string
  default     = "" # Should be set to the domain of Amplify or your backend domain
}

variable "main_vpc_id" {
  description = "ID of the main VPC"
  type        = string
  default     = ""
}

variable "public_web_subnet_a_id" {
  description = "ID of the public web subnet A"
  type        = string
  default     = ""
}

variable "public_web_subnet_b_id" {
  description = "ID of the public web subnet B"
  type        = string
  default     = ""
}

variable "fastapi_backend_app_cert_arn" {
  description = "ARN of the ACM certificate for the FastAPI backend application"
  type        = string
  default     = ""
}
