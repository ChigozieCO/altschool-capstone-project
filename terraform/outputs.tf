output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.eks.cluster_oidc_issuer_url
}

output "aws_account_id" {
  description = "Account Id of your AWS account"
  sensitive = true
  value = data.aws_caller_identity.current.account_id
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  sensitive = true
  value = module.eks.cluster_certificate_authority_data
}

output "ingress_load_balancer_dns" {
  description = "The dns name of the ingress controller's loadbalancer"
  value = data.kubernetes_service.ingress-nginx-controller.status[0].load_balancer[0].ingress[0].hostname
}

output "ingress_load_balancer_zone_id" {
  value = data.aws_lb.ingress_nginx_lb.zone_id
}