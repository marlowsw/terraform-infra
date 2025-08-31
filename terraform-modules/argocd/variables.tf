# terraform-modules/argocd/variables.tf

variable "namespace" {
  description = "Namespace for ArgoCD"
  type        = string
  default     = "argocd"
}
