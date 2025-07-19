module "vpc" {
  source = "./modules/vpc"

  vpc_cidr_block     = "10.16.0.0/16"
  vpc_name           = "iam-policy-generator-main-vpc"
  availability_zones = ["us-east-1a", "us-east-1b"]
}