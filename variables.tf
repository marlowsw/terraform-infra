variable "kubeconfig_path" {
  description = "Path to your kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "namespace" {
  description = "Namespace to create"
  type        = string
  default     = "terraform-demo"
}

