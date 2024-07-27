resource "kubectl_manifest" "cert_manager_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "projectchigozie-cert"
      namespace = "cert-manager" # Use the cert-manager namespace
    }
    spec = {
      secretName = "projectchigozie-tls" # The secret where the certificate will be stored
      issuerRef = {
        name = kubectl_manifest.cert_manager_cluster_issuer.manifest.metadata.name
        kind = "ClusterIssuer"
        namespace = "cert-manager" # Reference the correct namespace
      }
      commonName = "projectchigozie.me"
      dnsNames = [
        "projectchigozie.me",
        "*.projectchigozie.me"
      ]
      acme = {
        config = [{
          dns01 = {
            provider = "route53"
          }
          domains = [
            "projectchigozie.me",
            "*.projectchigozie.me"
          ]
        }]
      }
    }
  }
}
