# Deploy some RBAC to the cluster
resource "kubectl_manifest" "cert-manager-tokenrequest" {
  yaml_body = <<YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: cert-manager-tokenrequest
  namespace: cert-manager
rules:
  - apiGroups: [""]
    resources: ["serviceaccounts/token"]
    resourceNames: ["cert-manager"]
    verbs: ["create"]
YAML
}

# Deploy a RoleBinding to the cluster
resource "kubectl_manifest" "cmtokenrequest" {
  yaml_body = <<YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: cert-manager-cert-manager-tokenrequest
  namespace: cert-manager
subjects:
  - kind: ServiceAccount
    name: cert-manager
    namespace: cert-manager
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: cert-manager-tokenrequest
YAML
}