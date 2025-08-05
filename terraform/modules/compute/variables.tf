variable "fastapi_backend_app_server_lt_name" {
  description = "Name prefix for the backend application server launch template"
  type        = string
  default     = "fastapi_backend_app_server_"
}

variable "fastapi_backend_app_server_instance_type" {
  description = "EC2 instance type for the backend application server"
  type        = string
  default     = "t2.micro"
}

variable "main_vpc_id" {
  description = "ID of the main VPC where backend servers are deployed"
  type        = string
  default     = ""
}

variable "private_app_subnet_a_id" {
  description = "ID of the private application subnet in availability zone A"
  type        = string
  default     = ""
}

variable "private_app_subnet_b_id" {
  description = "ID of the private application subnet in availability zone B"
  type        = string
  default     = ""
}

variable "alb_sg_id" {
  description = "Security group ID for the Application Load Balancer"
  type        = string
  default     = ""
}

variable "fastapi_backend_app_server_tg_arn" {
  description = "ARN of the target group for the FastAPI backend application server"
  type        = string
  default     = ""
}
