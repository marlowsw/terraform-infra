variable "namespace" {
  description = "Kubernetes namespace for Jellyfin"
  type        = string
  default     = "jellyfin"
}

variable "nfs_server" {
  description = "NFS server hosting the Jellyfin data"
  type        = string
  default     = "10.0.0.9"
}

variable "nfs_share" {
  description = "NFS export containing the Jellyfin config and media directories"
  type        = string
  default     = "/Volume2/Labdata/jellyfin"
}

variable "storage_size" {
  description = "Capacity requested by the Jellyfin PVC"
  type        = string
  default     = "1Ti"
}

variable "gpu_node" {
  description = "Kubernetes node where Jellyfin should run"
  type        = string
  default     = "rancher-gpu1"
}
