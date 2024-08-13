# Add the providers
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "sockshop-statefiles"
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "sock-shop-lockfile"
  }

}

# Configure the AWS Provider
provider "aws" {
  region = var.region
  shared_credentials_files = ["~/.aws/credentials"]
}