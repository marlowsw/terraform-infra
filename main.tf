# ~/terraform/terraform-infra/main.tf

module "infra" {
  source    = "./terraform-modules/infra"
  namespace = var.namespace
}

module "argocd" {
  source    = "./terraform-modules/argocd"
  namespace = "argocd"

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
}

module "jellyfin" {
  source = "./terraform-modules/jellyfin"

  namespace    = "jellyfin"
  nfs_server   = "10.0.0.9"
  nfs_share    = "/Volume2/Labdata/jellyfin"
  storage_size = "1Ti"

  providers = {
    kubernetes = kubernetes
  }
}

module "ollama" {
  source = "./terraform-modules/ollama"

  namespace = "ollama"

  ollama_nodeport    = 31434
  openwebui_nodeport = 30081

  storage_class = "nfs-csi"

  ollama_storage_size    = "100Gi"
  openwebui_storage_size = "20Gi"

  gpu_node = "rancher-gpu1"
}

