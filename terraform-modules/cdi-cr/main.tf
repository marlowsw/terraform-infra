terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}
resource "kubernetes_manifest" "cdi_cr" {

  manifest = yamldecode(
    file("${path.module}/cdi-cr.yaml")
  )

}
