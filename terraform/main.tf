module "vpc" {
  source = "./modules/vpc"
}

module "compute" {
  source                            = "./modules/compute"
  main_vpc_id                       = module.vpc.main_vpc_id
  private_app_subnet_a_id           = module.vpc.private_app_subnet_a_id
  private_app_subnet_b_id           = module.vpc.private_app_subnet_b_id
  alb_sg_id                         = module.alb.alb_sg_id
  fastapi_backend_app_server_tg_arn = module.alb.fastapi_backend_app_server_tg_arn
}

module "alb" {
  source                 = "./modules/alb"
  main_vpc_id            = module.vpc.main_vpc_id
  public_web_subnet_a_id = module.vpc.public_web_subnet_a_id
  public_web_subnet_b_id = module.vpc.public_web_subnet_b_id
}