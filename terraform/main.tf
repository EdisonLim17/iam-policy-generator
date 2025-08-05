# VPC Module: Creates all networking components (VPC, subnets, routing, etc.)
module "vpc" {
  source = "./modules/vpc"
}

# Compute Module: Deploys EC2 backend (FastAPI app server)
module "compute" {
  source = "./modules/compute"

  # Networking
  main_vpc_id             = module.vpc.main_vpc_id
  private_app_subnet_a_id = module.vpc.private_app_subnet_a_id
  private_app_subnet_b_id = module.vpc.private_app_subnet_b_id

  # Load Balancer integration
  alb_sg_id                         = module.alb.alb_sg_id
  fastapi_backend_app_server_tg_arn = module.alb.fastapi_backend_app_server_tg_arn
}

# ALB Module: Creates Application Load Balancer and Target Groups
module "alb" {
  source = "./modules/alb"

  # Networking
  main_vpc_id            = module.vpc.main_vpc_id
  public_web_subnet_a_id = module.vpc.public_web_subnet_a_id
  public_web_subnet_b_id = module.vpc.public_web_subnet_b_id

  # SSL Certificate for HTTPS (issued in domain module)
  fastapi_backend_app_cert_arn = module.domain.iam_policy_generator_backend_cert_arn
}

# Domain Module: Configures Route 53 records for frontend + backend
module "domain" {
  source = "./modules/domain"

  # Backend domain record (ALB)
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id

  # Frontend domain record (Amplify)
  amplify_app_id         = module.frontend.amplify_app_id
  amplify_branch_name    = module.frontend.amplify_branch_name
  amplify_default_domain = module.frontend.amplify_default_domain

  # Explicitly specify provider aliases to create resources in the general account
  providers = {
    aws                 = aws
    aws.general_account = aws.general_account
  }
}

# Frontend Module: Deploys frontend using AWS Amplify
module "frontend" {
  source = "./modules/frontend"
}

# Database Module: Creates RDS instance for FastAPI backend
module "database" {
  source = "./modules/database"

  # Networking
  private_db_subnet_a_id = module.vpc.private_db_subnet_a_id
  private_db_subnet_b_id = module.vpc.private_db_subnet_b_id
  main_vpc_id            = module.vpc.main_vpc_id

  # Security
  backend_app_sg_id = module.compute.fastapi_backend_app_server_sg_id
}