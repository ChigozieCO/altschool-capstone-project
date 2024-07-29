# Resource to create the certificate
resource "kubectl_manifest" "cert_manager_certificate" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${var.domain}-cert
  namespace: cert-manager 
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
  acme:
    config:
      - dns01:
          provider: route53
        domains:
          - ${var.domain}
          - "*.${var.domain}"
YAML
}