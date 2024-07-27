# Create a cert-manager namespace that our service account will use
resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

# Add the cert-manager.crds.yaml file to enable Terraform to keep the management of these resources within Terraform's state and lifecycle management while leveraging existing YAML definitions.
resource "kubectl_manifest" "cert_manager_crds" {
  yaml_body = file("${path.module}/cert-manager.crds.yaml")
}

# Add the cert-manager.yaml file to enable Terraform to keep the management of these resources within Terraform's state and lifecycle management while leveraging existing YAML definitions.
resource "kubectl_manifest" "cert_manager" {
  yaml_body = file("${path.module}/cert-manager.yaml")
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