# # Define the YAML content as a local variable
# locals {
#   yaml_content = file("${path.module}/ingress-controller.yaml")
#   yaml_documents = split("---", local.yaml_content)
# }

data "kubectl_path_documents" "ingress-controller" {
  pattern = "${path.module}/ingress-controller.yaml"
}

# Split the YAML content into individual documents and create the ingress-controller
resource "kubectl_manifest" "ingress_controller" {
  for_each = { for idx, doc in data.kubectl_path_documents.ingress-controller.documents : idx => doc }
  yaml_body = each.value
}

# Create an Ingress resource using the kubectl_manifest resource
resource "kubectl_manifest" "ingress" {
  yaml_body = <<YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress
  namespace: sock-shop
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: "letsencrypt-staging"
    certmanager.k8s.io/acme-challenge-type: dns01
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  tls:
  - hosts:
    - ${var.domain}
    - "www.${var.domain}"
  secretName: "${var.domain}-tls"
  rules:
  - host: ${var.domain}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: front-end
            port:
              number: 80
  - host: "www.${var.domain}"
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: front-end
            port:
              number: 80
YAML
}

# Retrieve the ingress load balancer hostname
data "kubernetes_service" "ingress-nginx-controller" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }

  # Ensure this data source fetches after the service is created
  depends_on = [
    kubectl_manifest.ingress_controller
  ]
}

# Fetch the AWS Load Balancer using the DNS name from the Kubernetes service
data "aws_lb" "ingress_nginx_lb" {
  name = data.kubernetes_service.ingress-nginx-controller.status[0].load_balancer[0].ingress[0].ip
}

# Route 53 record creation so that our ingress controller can point to our domain name
resource "aws_route53_record" "ingress_load_balancer" {
  zone_id = data.aws_route53_zone.selected.zone_id  # Replace with your Route 53 Hosted Zone ID
  name    = var.domain # Replace with the DNS name you want
  type    = "A"

  # Use the LoadBalancer's external IP or DNS name
  alias {
    name                   = data.aws_lb.ingress_nginx_lb.dns_name
    zone_id                = data.aws_lb.ingress_nginx_lb.zone_id  # zone ID for the alias
    evaluate_target_health = true
  }
}