resource "helm_release" "homepage" {

  name = "homepage"

  repository = "https://jameswynn.github.io/helm-charts"

  chart = "homepage"

  namespace = "homepage"

  create_namespace = true

  timeout = 600
}
