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

