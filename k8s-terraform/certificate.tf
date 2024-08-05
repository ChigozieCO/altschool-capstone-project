# Create a sock-shop namespace that our service account will use
resource "kubernetes_namespace" "sock-shop" {
  metadata {
    name = "sock-shop"
  }
}

# Resource to create the certificate
resource "kubectl_manifest" "cert_manager_certificate" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${var.domain}-cert
  namespace: sock-shop  
spec:
  secretName: ${var.domain}-tls
  issuerRef:
    name: letsencrypt-staging
    kind: ClusterIssuer
    group: cert-manager.io
  commonName: ${var.domain}
  dnsNames:
    - ${var.domain}
    - "*.${var.domain}"
YAML
depends_on = [ kubernetes_namespace.sock-shop, kubectl_manifest.cert_manager_cluster_issuer ]
}

# Create a monitoring namespace
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

# Copy the certificate secret from the sock-shop namespace to the monitoring namespace
resource "kubernetes_secret" "monitoring_secret" {
  depends_on = [null_resource.fetch_sock_shop_cert, kubernetes_namespace.monitoring]

  metadata {
    name      = jsondecode(data.external.cert_secret.result)["metadata"]["name"]
    namespace = "monitoring"
  }

  data = {
    tls.crt = jsondecode(data.external.cert_secret.result)["data"]["tls.crt"]
    tls.key = jsondecode(data.external.cert_secret.result)["data"]["tls.key"]
  }

  type = "kubernetes.io/tls"
}
