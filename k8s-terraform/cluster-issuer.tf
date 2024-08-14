# Create the Cluster Issuer for the production environment
resource "kubectl_manifest" "cert_manager_cluster_issuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ${var.email}
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - dns01:
        route53:
          region: ${data.aws_region.current.name}
          hostedZoneID: ${data.aws_route53_zone.selected.zone_id}
        auth:
            kubernetes:
              serviceAccountRef: 
                name: cert-manager
                namespace: cert-manager
YAML
  depends_on = [helm_release.cert_manager]
}