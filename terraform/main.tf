# Copyright (c) HashiCorp, Inc.
# Add the AWS provider
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
  shared_credentials_files = ["~/.aws/credentials"]
}

# Configure the kubernetes Provider
provider "kubernetes" {
  host = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token = data.aws_eks_cluster_auth.cluster.token
}

# Configure kubectl provider
provider "kubectl" {}