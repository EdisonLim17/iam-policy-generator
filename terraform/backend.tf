terraform {
  backend "s3" {
    bucket       = "iam-policy-generator-tf-state"
    key          = "terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}