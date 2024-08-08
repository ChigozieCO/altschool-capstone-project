variable "domain" {
  description = "The domain name to access your application from and use in the creation of your SSL certificate"
  type = string
}

variable "region" {
  description = "The region where the VPC will be located"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  type        = string
}

variable "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  type        = string
}

variable "email" {
  description = "The email address to use in the creation of your SSL certificate"
  type = string
}

variable "slack-hook-url" {
  description = "The URL of your slack incoming webhook"
  type = string
}