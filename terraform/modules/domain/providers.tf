terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
      # Define alias for multiple AWS provider configurations (e.g., for different AWS accounts)
      configuration_aliases = [ aws.general_account ]
    }
  }
}
