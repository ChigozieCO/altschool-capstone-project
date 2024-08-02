# Retrieve all YAML resources defined in the specified file.
data "kubectl_path_documents" "sock-shop" {
  pattern = "${path.module}/complete-demo.yaml"
}

# Deploy your application in your EKS cluster
resource "kubectl_manifest" "socks-shop" {
  for_each = { for idx, doc in data.kubectl_path_documents.sock-shop.documents : idx => doc }
  yaml_body = each.value
  depends_on = [
    module.eks
  ]
}