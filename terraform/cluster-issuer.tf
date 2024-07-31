# Retrieve details of the current AWS region to dynamically reference it in the configuration
data "aws_region" "current" {}

# Retrieve the Route53 hosted zone for the domain
data "aws_route53_zone" "selected" {
  name         = var.domain
}

# Create the Cluster Issuer for the production environment
resource "kubectl_manifest" "cert_manager_cluster_issuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: ${var.email}
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
    - dns01:
        route53:
          region: ${data.aws_region.current.name}
          hostedZoneID: ${data.aws_route53_zone.selected.zone_id}
          role: arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Route53CertManagerRole
        auth:
            kubernetes:
              serviceAccountRef: 
                name: cert-manager
                namespace: cert-manager
YAML
  depends_on = [kubectl_manifest.cert_manager]
}