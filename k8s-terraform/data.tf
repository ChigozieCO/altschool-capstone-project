# Retrieves the current AWS account ID to dynamically reference it in the policy document
data "aws_caller_identity" "current" {}

# Retrieve details of the current AWS region to dynamically reference it in the configuration
data "aws_region" "current" {}

# Retrieve the eks cluster endpoint from AWS
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

# Retrieve the Route53 hosted zone for the domain
data "aws_route53_zone" "selected" {
  name         = var.domain
}

# Retrieve the ingress load balancer hostname
data "kubernetes_service" "ingress-nginx-controller" {
  metadata {
    name      = "nginx-ingress-ingress-nginx-controller"
    namespace = "ingress-nginx"
  }

  # Ensure this data source fetches after the service is created
  depends_on = [
    helm_release.ingress-nginx
  ]
}

# Extract the load balancer name from the hostname
locals {
  ingress_list = data.kubernetes_service.ingress-nginx-controller.status[0].load_balancer[0].ingress
  lb_hostname  = element(local.ingress_list, 0).hostname
  lb_name     = join("", slice(split("-", local.lb_hostname), 0, 1))
}

# Data source to fetch the AWS ELB details using the extracted load balancer name
data "aws_elb" "ingress_nginx_lb" {
  name = local.lb_name
}