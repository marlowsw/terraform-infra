resource "kubernetes_namespace_v1" "jellyfin" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_storage_class_v1" "jellyfin_nfs" {
  metadata {
    name = "jellyfin-nfs"
  }

  storage_provisioner    = "nfs.csi.k8s.io"
  reclaim_policy         = "Retain"
  volume_binding_mode    = "Immediate"
  allow_volume_expansion = true

  mount_options = [
    "hard",
    "nfsvers=4.1"
  ]

  parameters = {
    server = var.nfs_server
    share  = var.nfs_share
  }
}

resource "kubernetes_persistent_volume_v1" "jellyfin" {
  metadata {
    name = "jellyfin-data-pv"
  }

  spec {
    capacity = {
      storage = var.storage_size
    }

    access_modes = [
      "ReadWriteMany"
    ]

    persistent_volume_reclaim_policy = "Retain"

    storage_class_name = kubernetes_storage_class_v1.jellyfin_nfs.metadata[0].name

    mount_options = [
      "hard",
      "nfsvers=4.1"
    ]

    persistent_volume_source {
      csi {
        driver = "nfs.csi.k8s.io"

        volume_handle = "jellyfin-data"

        volume_attributes = {
          server = var.nfs_server
          share  = var.nfs_share
        }
      }
    }
  }

  depends_on = [
    kubernetes_storage_class_v1.jellyfin_nfs
  ]
}

resource "kubernetes_persistent_volume_claim_v1" "jellyfin" {
  metadata {
    name      = "jellyfin-data"
    namespace = kubernetes_namespace_v1.jellyfin.metadata[0].name
  }

  spec {
    access_modes = [
      "ReadWriteMany"
    ]

    storage_class_name = kubernetes_storage_class_v1.jellyfin_nfs.metadata[0].name

    volume_name = kubernetes_persistent_volume_v1.jellyfin.metadata[0].name

    resources {
      requests = {
        storage = var.storage_size
      }
    }
  }

  depends_on = [
    kubernetes_persistent_volume_v1.jellyfin
  ]
}

resource "kubernetes_deployment_v1" "jellyfin" {
  metadata {
    name      = "jellyfin"
    namespace = kubernetes_namespace_v1.jellyfin.metadata[0].name

    labels = {
      app = "jellyfin"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "jellyfin"
      }
    }

    template {
      metadata {
        labels = {
          app = "jellyfin"
        }
      }

      spec {
        node_selector = {
          "kubernetes.io/hostname" = var.gpu_node
        }

        security_context {
          fs_group = 1000
        }

        container {
          name  = "jellyfin"
          image = "jellyfin/jellyfin:latest"

          image_pull_policy = "IfNotPresent"

          port {
            name           = "http"
            container_port = 8096
            protocol       = "TCP"
          }

          env {
            name  = "JELLYFIN_PublishedServerUrl"
            value = "http://localhost:8096"
          }

          volume_mount {
            name       = "jellyfin-data"
            mount_path = "/config"
            sub_path   = "config"
          }

          volume_mount {
            name       = "jellyfin-data"
            mount_path = "/media"
            sub_path   = "media"
            read_only  = true
          }

          resources {
            requests = {
              cpu              = "250m"
              memory           = "512Mi"
              "nvidia.com/gpu" = "1"
            }

            limits = {
              cpu              = "4"
              memory           = "16Gi"
              "nvidia.com/gpu" = "1"
            }
          }
        }

        volume {
          name = "jellyfin-data"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.jellyfin.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_persistent_volume_claim_v1.jellyfin
  ]
}

resource "kubernetes_service_v1" "jellyfin" {
  metadata {
    name      = "jellyfin"
    namespace = kubernetes_namespace_v1.jellyfin.metadata[0].name
  }

  spec {
    type = "NodePort"

    selector = {
      app = "jellyfin"
    }

    port {
      name        = "http"
      port        = 8096
      target_port = 8096
      node_port   = 30096
      protocol    = "TCP"
    }
  }

  depends_on = [
    kubernetes_deployment_v1.jellyfin
  ]
}
