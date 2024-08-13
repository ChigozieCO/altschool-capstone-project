# Add required providers
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }

    helm = {
      source  = "hashicorp/helm"
    }
  }

  backend "s3" {
    bucket         = "sockshop-statefiles"
    key            = "k8s/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "sock-shop-lockfile"
  }

}

# Configure the AWS Provider
provider "aws" {
  region = var.region
  shared_credentials_files = ["~/.aws/credentials"]
}

# Configure the kubernetes Provider, the exec will use the aws cli to retrieve the token 
provider "kubernetes" {
  host = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
  }
}

# Configure the kubernetes Provider, the exec will use the aws cli to retrieve the token 
provider "kubectl" {
  host = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
  }
}

# Configure the helm Provider using the kubernetes configuration
provider "helm" {
  kubernetes {
    host = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    }
  }
}