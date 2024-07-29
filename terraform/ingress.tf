# Create the Ingress Controller
resource "kubectl_manifest" "ingress_controller" {
  yaml_body = file("${path.module}/ingress-controller.yaml")
}

# Create an Ingress resource using the kubectl_manifest resource
resource "kubectl_manifest" "ingress" {
  yaml_body = <<YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: "letsencrypt-staging"
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  tls:
    - hosts:
      - ${var.domain}
    - hosts:
      - "www.${var.domain}"
    secretName: "${var.domain}-tls"
  rules:
    - host: ${var.domain}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: front-end
                port:
                  number: 80
    - host: "www.${var.domain}"
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: front-end
                port:
                  number: 80
YAML
}