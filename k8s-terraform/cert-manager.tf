# Create a cert-manager namespace that our service account will use
resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

# Create the service account for cert-manager
resource "kubernetes_service_account" "cert_manager" {
  metadata {
    name      = "cert-manager"
    namespace = "cert-manager"
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Route53CertManagerRole"
    }
  }
}

# Use Helm to deploy the cert-manager
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  create_namespace = false
  cleanup_on_fail = true
  force_update = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.cert_manager.metadata[0].name
  }

  set {
    name  = "securityContext.fsGroup"
    value = "1001"
  }

  set {
    name  = "controller.config.cleanup"
    value = "true"
  }

  set {
    name = "helm.sh/resource-policy"
    value = "delete"
  }

  depends_on = [ kubernetes_service_account.cert_manager, kubernetes_namespace.cert-manager, helm_release.ingress-nginx ]
}

# # Apply resource policy to delete CRDs
# resource "kubectl_manifest" "cert_manager_crds" {
#   for_each = toset([
#     "certificaterequests.cert-manager.io",
#     "certificates.cert-manager.io",
#     "challenges.acme.cert-manager.io",
#     "clusterissuers.cert-manager.io",
#     "issuers.cert-manager.io",
#     "orders.acme.cert-manager.io",
#   ])

#   yaml_body = <<YAML
# apiVersion: apiextensions.k8s.io/v1
# kind: CustomResourceDefinition
# metadata:
#   name: ${each.key}
#   annotations:
#     helm.sh/resource-policy: delete
# YAML
# }