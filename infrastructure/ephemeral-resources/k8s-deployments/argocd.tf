resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  namespace        = "argocd"
  create_namespace = true

  # Change ArgoCD k8s service from Cluster IP to LoadBalancer
  # https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd/values.yaml#L1808C20-L1808C20
  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }
}
