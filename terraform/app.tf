# Deploy your application in your EKS cluster
resource "kubectl_manifest" "socks-shop" {
  yaml_body = file("${path.module}/complete-demo.yaml") # Replace with your actual manifest file
  depends_on = [
    module.eks
  ]
}