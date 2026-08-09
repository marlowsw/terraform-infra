terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}
resource "kubernetes_namespace_v1" "goldpinger" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_service_account_v1" "goldpinger" {

  metadata {
    name      = "goldpinger"
    namespace = kubernetes_namespace_v1.goldpinger.metadata[0].name
  }
}

resource "kubernetes_cluster_role_v1" "goldpinger" {

  metadata {
    name = "goldpinger"
  }

  rule {

    api_groups = [""]
    resources = [
      "pods",
      "nodes",
      "services",
      "endpoints"
    ]

    verbs = [
      "get",
      "list",
      "watch"
    ]
  }
}

resource "kubernetes_cluster_role_binding_v1" "goldpinger" {

  metadata {
    name = "goldpinger"
  }


  role_ref {

    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.goldpinger.metadata[0].name
  }


  subject {

    kind = "ServiceAccount"

    name = kubernetes_service_account_v1.goldpinger.metadata[0].name

    namespace = kubernetes_namespace_v1.goldpinger.metadata[0].name
  }
}

resource "kubernetes_daemon_set_v1" "goldpinger" {

  metadata {
    name      = "goldpinger"
    namespace = kubernetes_namespace_v1.goldpinger.metadata[0].name

    labels = {
      app = "goldpinger"
    }
  }

  depends_on = [
    kubernetes_cluster_role_binding_v1.goldpinger
  ]

  spec {

    selector {
      match_labels = {
        app = "goldpinger"
      }
    }


    template {

      metadata {
        labels = {
          app = "goldpinger"
        }
      }


      spec {

        toleration {
          key    = "node-role.kubernetes.io/control-plane"
          effect = "NoSchedule"
        }

        toleration {
          key    = "node-role.kubernetes.io/master"
          effect = "NoSchedule"
        }

        service_account_name = kubernetes_service_account_v1.goldpinger.metadata[0].name

        container {

          name  = "goldpinger"
          image = var.image

          image_pull_policy = "IfNotPresent"

          args = [
            "--host=0.0.0.0",
            "--port=8080"
          ]

          port {
            name           = "http"
            container_port = 8080
            protocol       = "TCP"
          }


          env {
            name = "POD_IP"
            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }


          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }


          resources {

            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }

            limits = {
              cpu    = "250m"
              memory = "256Mi"
            }

          }


          readiness_probe {

            http_get {
              path = "/healthz"
              port = 8080
            }

            initial_delay_seconds = 5
            period_seconds        = 10
          }


          liveness_probe {

            http_get {
              path = "/healthz"
              port = 8080
            }

            initial_delay_seconds = 15
            period_seconds        = 20
          }

        }
      }
    }
  }
}


resource "kubernetes_service_v1" "goldpinger" {

  metadata {
    name      = "goldpinger"
    namespace = kubernetes_namespace_v1.goldpinger.metadata[0].name

    labels = {
      app = "goldpinger"
    }
  }


  spec {

    type = "NodePort"


    selector = {
      app = "goldpinger"
    }


    port {

      name = "http"

      port = 80

      target_port = 8080

      node_port = 31078

      protocol = "TCP"
    }
  }


  depends_on = [
    kubernetes_daemon_set_v1.goldpinger
  ]
}
resource "kubernetes_manifest" "goldpinger_service_monitor" {

  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"

    metadata = {
      name      = "goldpinger"
      namespace = var.namespace

      labels = {
        release = "rancher-monitoring"
      }
    }

    spec = {

      selector = {
        matchLabels = {
          app = "goldpinger"
        }
      }

      namespaceSelector = {
        matchNames = [
          var.namespace
        ]
      }

      endpoints = [
        {
          port     = "http"
          path     = "/metrics"
          interval = "30s"
        }
      ]
    }
  }

  depends_on = [
    kubernetes_service_v1.goldpinger
  ]
}
