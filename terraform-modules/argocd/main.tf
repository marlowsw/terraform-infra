terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }

    helm = {
      source = "hashicorp/helm"
    }
  }
}
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "argocd" {
  provider   = helm # <-- add this line
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "8.3.1"

  values = [
    yamlencode({
      server = {
        service = {
          type     = "NodePort" # or "ClusterIP" if you prefer
          nodePort = 30080
        }
      }
    })
  ]
}
