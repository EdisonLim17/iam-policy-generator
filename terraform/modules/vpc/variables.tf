variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.16.0.0/16"
}

variable "vpc_name" {
  description = "The name of the VPC."
  type        = string
  default     = "iam_policy_generator_main_vpc"
}

variable "availability_zones" {
  description = "List of availability zones to use for the subnets."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_web_subnet_a_name" {
  description = "Name for the public web subnet in availability zone A."
  type        = string
  default     = "public_web_subnet_a"
}

variable "public_web_subnet_b_name" {
  description = "Name for the public web subnet in availability zone B."
  type        = string
  default     = "public_web_subnet_b"
}

variable "private_app_subnet_a_name" {
  description = "Name for the private app subnet in availability zone A."
  type        = string
  default     = "private_app_subnet_a"
}

variable "private_app_subnet_b_name" {
  description = "Name for the private app subnet in availability zone B."
  type        = string
  default     = "private_app_subnet_b"
}

variable "private_db_subnet_a_name" {
  description = "Name for the private DB subnet in availability zone A."
  type        = string
  default     = "private_db_subnet_a"
}

variable "private_db_subnet_b_name" {
  description = "Name for the private DB subnet in availability zone B."
  type        = string
  default     = "private_db_subnet_b"
}

variable "public_web_subnet_a_nat_gateway_name" {
  description = "Name for the NAT gateway in public web subnet A."
  type        = string
  default     = "public_web_subnet_a_nat_gateway"
}

variable "public_web_subnet_a_nat_eip_name" {
  description = "Name for the EIP associated with the NAT gateway in public web subnet A."
  type        = string
  default     = "public_web_subnet_a_nat_eip"
}

variable "public_web_subnet_b_nat_gateway_name" {
  description = "Name for the NAT gateway in public web subnet B."
  type        = string
  default     = "public_web_subnet_b_nat_gateway"
}

variable "public_web_subnet_b_nat_eip_name" {
  description = "Name for the EIP associated with the NAT gateway in public web subnet B."
  type        = string
  default     = "public_web_subnet_b_nat_eip"
}

variable "igw_name" {
  description = "Name for the internet gateway."
  type        = string
  default     = "igw"
}

variable "public_route_table_name" {
  description = "Name for the public route table."
  type        = string
  default     = "public_route_table"
}

variable "private_app_subnet_a_route_table_name" {
  description = "Name for the private route table."
  type        = string
  default     = "private_app_subnet_a_route_table"
}

variable "private_app_subnet_b_route_table_name" {
  description = "Name for the private route table in subnet B."
  type        = string
  default     = "private_app_subnet_b_route_table"
}

variable "private_db_subnet_a_route_table_name" {
  description = "Name for the private DB route table in subnet A."
  type        = string
  default     = "private_db_subnet_a_route_table"
}

variable "private_db_subnet_b_route_table_name" {
  description = "Name for the private DB route table in subnet B."
  type        = string
  default     = "private_db_subnet_b_route_table"
}