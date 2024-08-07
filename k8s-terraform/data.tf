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

# Retrieve the certificate secret and copy to the monitoring namespace
resource "null_resource" "copy_secret" {
  provisioner "local-exec" {
    command = <<EOT
      aws eks update-kubeconfig --region us-east-1 --name sock-shop-eks && \
      
      # Wait for the secret to be created by cert-manager
      WAIT_RETRIES=80
      WAIT_DELAY=45
      for i in $(seq 1 $WAIT_RETRIES); do
        kubectl get secret projectchigozie.me-tls -n sock-shop && break || \
        echo "Waiting for the secret to be created... ($i/$WAIT_RETRIES)"
        sleep $WAIT_DELAY
      done && \
      
      # Retry applying the secret in case of concurrent modification
      RETRIES=10
      DELAY=5
      for i in $(seq 1 $RETRIES); do
        kubectl get secret projectchigozie.me-tls -n sock-shop -o yaml | sed 's/namespace: sock-shop/namespace: monitoring/' | kubectl apply -f - && break || \
        echo "Retrying in $DELAY seconds... ($i/$RETRIES)"
        sleep $DELAY
      done
    EOT
    interpreter = ["bash", "-c"]
  }
  # Ensure this data source fetches after the service is created
  depends_on = [kubectl_manifest.cert_manager_certificate]
}

# Retrieve the certificate secret and copy to the kube-system namespace
resource "null_resource" "copy_secret_kibana" {
  provisioner "local-exec" {
    command = <<EOT
      aws eks update-kubeconfig --region us-east-1 --name sock-shop-eks && \
      
      # Wait for the secret to be created by cert-manager
      WAIT_RETRIES=80
      WAIT_DELAY=45
      for i in $(seq 1 $WAIT_RETRIES); do
        kubectl get secret projectchigozie.me-tls -n sock-shop && break || \
        echo "Waiting for the secret to be created... ($i/$WAIT_RETRIES)"
        sleep $WAIT_DELAY
      done && \
      
      # Retry applying the secret in case of concurrent modification
      RETRIES=10
      DELAY=5
      for i in $(seq 1 $RETRIES); do
        kubectl get secret projectchigozie.me-tls -n sock-shop -o yaml | sed 's/namespace: sock-shop/namespace: kube-system/' | kubectl apply -f - && break || \
        echo "Retrying in $DELAY seconds... ($i/$RETRIES)"
        sleep $DELAY
      done
    EOT
    interpreter = ["bash", "-c"]
  }
  # Ensure this data source fetches after the service is created
  depends_on = [kubectl_manifest.cert_manager_certificate]
}