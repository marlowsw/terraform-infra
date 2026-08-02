resource "kubernetes_manifest" "cdi_cr" {

  manifest = yamldecode(
    file("${path.module}/cdi-cr.yaml")
  )

}
