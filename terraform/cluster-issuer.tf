# Retrieve details of the current AWS region to dynamically reference it in the configuration
data "aws_region" "current" {}

# Create the Cluster Issuer for the production environment
resource "kubernetes_manifest" "letsencrypt_staging_cluster_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-staging"
    }
    spec = {
      acme = {
        server = "https://acme-staging-v02.api.letsencrypt.org/directory"
        email  = "cnma.staging@gmail.com"
        privateKeySecretRef = {
          name = "letsencrypt-staging"
        }
        solvers = [
          {
            dns01 = {
              route53 = {
                region = var.region
              }
            }
          }
        ]
      }
    }
  }
}
