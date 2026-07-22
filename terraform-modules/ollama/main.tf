resource "kubernetes_namespace" "ollama" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_persistent_volume_claim" "ollama" {
  metadata {
    name      = "ollama-data"
    namespace = kubernetes_namespace.ollama.metadata[0].name
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = var.storage_class

    resources {
      requests = {
        storage = var.ollama_storage_size
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "openwebui" {
  metadata {
    name      = "open-webui-data"
    namespace = kubernetes_namespace.ollama.metadata[0].name
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = var.storage_class

    resources {
      requests = {
        storage = var.openwebui_storage_size
      }
    }
  }
}

resource "kubernetes_deployment" "ollama" {
  metadata {
    name      = "ollama"
    namespace = kubernetes_namespace.ollama.metadata[0].name

    labels = {
      app = "ollama"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "ollama"
      }
    }

    template {
      metadata {
        labels = {
          app = "ollama"
        }
      }

      spec {
        node_selector = {
          "kubernetes.io/hostname" = var.gpu_node
        }

        runtime_class_name = "nvidia"

        container {
          name              = "ollama"
          image             = "ollama/ollama:latest"
          image_pull_policy = "IfNotPresent"

          port {
            name           = "ollama"
            container_port = 11434
          }

          env {
            name  = "OLLAMA_HOST"
            value = "0.0.0.0:11434"
          }

          env {
            name  = "OLLAMA_KEEP_ALIVE"
            value = "-1"
          }

          resources {
            requests = {
              cpu    = "1"
              memory = "8Gi"
            }

            limits = {
              cpu              = "4"
              memory           = "24Gi"
              "nvidia.com/gpu" = "1"
            }
          }

          volume_mount {
            name       = "ollama-data"
            mount_path = "/root/.ollama"
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 11434
            }

            initial_delay_seconds = 30
            period_seconds        = 30
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 11434
            }

            initial_delay_seconds = 10
            period_seconds        = 10
          }
        }

        volume {
          name = "ollama-data"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.ollama.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "ollama" {
  metadata {
    name      = "ollama"
    namespace = kubernetes_namespace.ollama.metadata[0].name
  }

  spec {
    selector = {
      app = "ollama"
    }

    type = "NodePort"

    port {
      name        = "ollama"
      port        = 11434
      target_port = 11434
      node_port   = var.ollama_nodeport
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_deployment" "openwebui" {
  metadata {
    name      = "open-webui"
    namespace = kubernetes_namespace.ollama.metadata[0].name

    labels = {
      app = "open-webui"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "open-webui"
      }
    }

    template {
      metadata {
        labels = {
          app = "open-webui"
        }
      }

      spec {
        container {
          name              = "open-webui"
          image             = "ghcr.io/open-webui/open-webui:main"
          image_pull_policy = "IfNotPresent"

          port {
            name           = "http"
            container_port = 8080
          }

          env {
            name  = "OLLAMA_BASE_URL"
            value = "http://ollama:11434"
          }

          env {
            name  = "WEBUI_AUTH"
            value = "true"
          }

          resources {
            requests = {
              cpu    = "250m"
              memory = "512Mi"
            }

            limits = {
              cpu    = "2"
              memory = "4Gi"
            }
          }

          volume_mount {
            name       = "openwebui-data"
            mount_path = "/app/backend/data"
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 8080
            }

            initial_delay_seconds = 30
            period_seconds        = 30
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 8080
            }

            initial_delay_seconds = 10
            period_seconds        = 10
          }
        }

        volume {
          name = "openwebui-data"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.openwebui.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "openwebui" {
  metadata {
    name      = "open-webui"
    namespace = kubernetes_namespace.ollama.metadata[0].name
  }

  spec {
    selector = {
      app = "open-webui"
    }

    type = "NodePort"

    port {
      name        = "http"
      port        = 8080
      target_port = 8080
      node_port   = var.openwebui_nodeport
      protocol    = "TCP"
    }
  }
}
