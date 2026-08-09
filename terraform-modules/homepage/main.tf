resource "helm_release" "homepage" {
  name = "homepage"

  repository = "https://jameswynn.github.io/helm-charts"
  chart      = "homepage"

  namespace        = var.namespace
  create_namespace = true

  timeout = 600

  values = [
    yamlencode({
      env = [
        {
          name  = "HOMEPAGE_ALLOWED_HOSTS"
          value = "rancher-worker2:30176"
        }
      ]

      service = {
        main = {
          type = "NodePort"

          ports = {
            http = {
              port     = 3000
              nodePort = 30176
            }
          }
        }
      }

      config = {
        bookmarks = yamldecode(file("${path.module}/config/bookmarks.yaml"))
        services  = yamldecode(file("${path.module}/config/services.yaml"))
        settings  = yamldecode(file("${path.module}/config/settings.yaml"))
        widgets   = yamldecode(file("${path.module}/config/widgets.yaml"))
      }
    })
  ]
}
