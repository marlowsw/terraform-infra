# ~/terraform/terraform-infra/variables.tf

variable "namespace" {
  description = "Namespace to create"
  type        = string
  default     = "terraform-demo"
}
