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