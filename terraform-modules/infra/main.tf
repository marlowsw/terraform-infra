terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}
# ~/terraform/terraform-modules/infra/main.tf

variable "namespace" {
  description = "Namespace for this deployment"
  type        = string
}

resource "kubernetes_namespace" "example" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "nginx-deployment"
    namespace = kubernetes_namespace.example.metadata[0].name
    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          image = "nginx:1.25"
          name  = "nginx"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

# optional if you want to deploy raw YAML as well
# resource "kubernetes_manifest" "nginx_deployment" {
#   manifest = yamldecode(file("${path.module}/nginx-deployment.yaml"))
# }

