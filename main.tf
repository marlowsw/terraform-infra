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

