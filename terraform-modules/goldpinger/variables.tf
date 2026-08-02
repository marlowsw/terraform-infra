variable "namespace" {
  description = "Goldpinger namespace"
  type        = string
  default     = "goldpinger"
}

variable "replicas" {
  description = "Number of Goldpinger replicas"
  type        = number
  default     = 3
}

variable "image" {
  description = "Goldpinger container image"
  type        = string
  default     = "bloomberg/goldpinger:3.11.2"
}
