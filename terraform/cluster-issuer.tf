# Retrieve details of the current AWS region to dynamically reference it in the configuration
data "aws_region" "current" {}

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
YAML
}