# Resource to create the certificate
resource "kubectl_manifest" "cert_manager_certificate" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: projectchigozie-cert
  namespace: cert-manager 
spec:
  secretName: projectchigozie-tls
  issuerRef:
    name: letsencrypt-staging
    kind: ClusterIssuer
    group: cert-manager.io
  commonName: projectchigozie.me
  dnsNames:
    - projectchigozie.me
    - "*.projectchigozie.me"
  acme:
    config:
      - dns01:
          provider: route53
        domains:
          - projectchigozie.me
          - "*.projectchigozie.me"
YAML
}