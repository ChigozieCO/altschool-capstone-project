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

# Create a kubernetes secret for alertmanager
resource "kubernetes_secret" "slack" {
  metadata {
    name = "slack-hook-url"
    namespace = kubernetes_namespace.monitoring.id
  }
  data = {
    "SLACK_HOOK_URL" = var.slack-hook-url
  }
  depends_on = [ kubernetes_namespace.monitoring ]
}