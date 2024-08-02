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
depends_on = [ helm_release.cert_manager, kubectl_manifest.cert_manager_cluster_issuer ]
}