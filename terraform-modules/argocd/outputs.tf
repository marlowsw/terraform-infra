# ~/terraform/terraform-infra/terraform-modules/argocd/outputs.tf

output "argocd_namespace" {
  value = kubernetes_namespace.argocd.metadata[0].name
}

output "argocd_helm_name" {
  value = helm_release.argocd.name
}
