variable "fastapi_backend_app_server_lt_name" {
    description = "Name for the backend application server"
    type        = string
    default     = "fastapi_backend_app_server_"
}

variable "fastapi_backend_app_server_instance_type" {
    description = "Instance type for the backend application server"
    type        = string
    default     = "t2.micro"
}

variable "main_vpc_id" {
    description = "ID of the main VPC"
    type        = string
    default     = ""
}

variable "private_app_subnet_a_id" {
    description = "ID of the private app subnet A"
    type        = string
    default     = ""
}

variable "private_app_subnet_b_id" {
    description = "ID of the private app subnet B"
    type        = string
    default     = ""
}

variable "alb_sg_id" {
    description = "ID of the security group for the ALB"
    type        = string
    default     = ""
}

variable "fastapi_backend_app_server_tg_arn" {
    description = "ARN of the FastAPI backend application server target group"
    type        = string
    default     = ""
}