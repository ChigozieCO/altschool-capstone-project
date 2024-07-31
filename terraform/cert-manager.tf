# Create a cert-manager namespace that our service account will use
resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

# # Define the YAML content as a local variable
# locals {
#   yaml_content = file("${path.module}/cert-manager.crds.yaml")
#   yaml_documents = split("---", local.yaml_content)
# }

# Retrieve all YAML resources defined in the specified file.
data "kubectl_path_documents" "cert_manager_crds" {
  pattern = "${path.module}/cert-manager.crds.yaml"
}

# Add the cert-manager.crds.yaml file by iterating over these documents, creating a kubectl_manifest resource for each one to enable Terraform to keep the management of these resources within Terraform's state and lifecycle management while leveraging existing YAML definitions.
resource "kubectl_manifest" "cert_manager_crds" {
  for_each = { for idx, doc in data.kubectl_path_documents.cert_manager_crds.documents : idx => doc }
  yaml_body = each.value
}

# Retrieve all YAML resources defined in the specified file.
data "kubectl_path_documents" "cert_manager" {
  pattern = "${path.module}/cert-manager.yaml"
}

# Add the cert-manager.yaml file by iterating over these documents, creating a kubectl_manifest resource for each one to enable Terraform to keep the management of these resources within Terraform's state and lifecycle management while leveraging existing YAML definitions.
resource "kubectl_manifest" "cert_manager" {
  for_each = { for idx, doc in data.kubectl_path_documents.cert_manager.documents : idx => doc }
  yaml_body = each.value
  depends_on = [ 
    kubernetes_service_account.cert_manager, 
    kubernetes_service_account.cert_manager_cainjector, 
    kubernetes_service_account.cert_manager_webhook  
  ]
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

# Create the service account for cert_manager_cainjector
resource "kubernetes_service_account" "cert_manager_cainjector" {
  metadata {
    name      = "cert-manager-cainjector"
    namespace = "cert-manager"
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Route53CertManagerRole"
    }
  }
}

# Create the service account for cert_manager_webhook
resource "kubernetes_service_account" "cert_manager_webhook" {
  metadata {
    name      = "cert-manager-webhook"
    namespace = "cert-manager"
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Route53CertManagerRole"
    }
  }
}