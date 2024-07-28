variable "region" {
  description = "The region where the VPC will be located"
  type        = string
  default     = "us-east-1"
}

variable "vpcname" {
  description = "Vpc name"
  type        = string
}

variable "cluster_name" {
  description = "Name of EKS cluster"
  type        = string
}

variable "namespace" {
  description = "The Kubernetes namespace for the service account"
  type        = string
}

variable "service_account_name" {
  description = "The name of the Kubernetes service account"
  type        = string
}

variable "email" {
  description = "The email address to use in the creation of your SSL certificate"
  type = string
}