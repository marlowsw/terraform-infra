# ~/terraform/terraform-infra/outputs.tf

output "namespace_name" {
  value = module.infra.namespace_name
}

output "nginx_deployment_name" {
  value = module.infra.nginx_deployment_name
}

output "argocd_namespace" {
  value = module.argocd.argocd_namespace
}

output "argocd_helm_name" {
  value = module.argocd.argocd_helm_name
}
