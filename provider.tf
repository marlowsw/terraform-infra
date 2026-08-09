terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.38.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.0"
    }

    time = {
      source  = "hashicorp/time"
      version = ">= 0.10"
    }
  }
}

provider "kubernetes" {
  config_path = "/home/smarz/terraform/terraform-infra/local.yaml"
}

provider "helm" {
  kubernetes = {
    config_path = "/home/smarz/terraform/terraform-infra/local.yaml"
  }
}

