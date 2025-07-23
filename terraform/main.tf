module "vpc" {
  source = "./modules/vpc"
}

module "compute" {
  source = "./modules/compute"

  main_vpc_id                       = module.vpc.main_vpc_id
  private_app_subnet_a_id           = module.vpc.private_app_subnet_a_id
  private_app_subnet_b_id           = module.vpc.private_app_subnet_b_id
  alb_sg_id                         = module.alb.alb_sg_id
  fastapi_backend_app_server_tg_arn = module.alb.fastapi_backend_app_server_tg_arn
}

module "alb" {
  source = "./modules/alb"

  main_vpc_id                  = module.vpc.main_vpc_id
  public_web_subnet_a_id       = module.vpc.public_web_subnet_a_id
  public_web_subnet_b_id       = module.vpc.public_web_subnet_b_id
  fastapi_backend_app_cert_arn = module.domain.iam_policy_generator_backend_cert_arn
}

module "domain" {
  source = "./modules/domain"

  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id

  providers = {
    aws                 = aws
    aws.general_account = aws.general_account
  }
}

module "frontend" {
  source = "./modules/frontend"
}