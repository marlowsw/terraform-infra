variable "namespace" {
  description = "Kubernetes namespace for Ollama and Open WebUI"
  type        = string
  default     = "ollama"
}

variable "ollama_nodeport" {
  description = "NodePort for Ollama"
  type        = number
  default     = 31434
}

variable "openwebui_nodeport" {
  description = "NodePort for Open WebUI"
  type        = number
  default     = 30080
}

variable "storage_class" {
  description = "StorageClass used for persistent storage"
  type        = string
  default     = "nfs-csi"
}

variable "ollama_storage_size" {
  description = "Persistent storage size for Ollama models"
  type        = string
  default     = "100Gi"
}

variable "openwebui_storage_size" {
  description = "Persistent storage size for Open WebUI"
  type        = string
  default     = "20Gi"
}

variable "gpu_node" {
  description = "GPU worker node name"
  type        = string
  default     = "rancher-gpu1"
}
