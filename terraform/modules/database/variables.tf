variable "instance_identifier" {
  description = "The identifier for the database instance."
  type        = string
  default = "iam-policy-generator-db-instance"
}

variable "db_name" {
  description = "The name of the database to create."
  type        = string
  default = "IAMPolicyGeneratorDB"
}

variable "allocated_storage" {
  description = "The amount of allocated storage in gigabytes."
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "The storage type for the database."
  type        = string
  default     = "gp3"
}

variable "engine" {
  description = "The database engine to use."
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "The version of the database engine."
  type        = string
  default     = "17.4"
}

variable "instance_class" {
  description = "The instance class for the database."
  type        = string
  default     = "db.t4g.micro"
}

variable "port" {
  description = "The port on which the database is accessible."
  type        = number
  default     = 5432
}

variable "publicly_accessible" {
  description = "Whether the database instance is publicly accessible."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "The number of days to retain backups for the database."
  type        = number
  default     = 7
}

variable "private_db_subnet_a_id" {
  description = "The name of the primary DB subnet group."
  type        = string
}

variable "private_db_subnet_b_id" {
  description = "The name of the standby DB subnet group."
  type        = string
}

variable "db_subnet_group_name" {
  description = "The name of the database subnet group."
  type        = string
  default     = "iam-policy-generator-db-subnet-group"
}

variable "main_vpc_id" {
  description = "The ID of the main VPC."
  type        = string
}

variable "backend_app_sg_id" {
  description = "The ID of the security group for the backend application server."
  type        = string
}