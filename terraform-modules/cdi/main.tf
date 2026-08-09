terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}
locals {
  cdi_documents = [
    for doc in split("\n---", file("${path.module}/cdi-operator.yaml")) :
    trimspace(doc)
    if trimspace(doc) != ""
    && can(yamldecode(doc))
  ]

  cdi_manifests = {
    for doc in local.cdi_documents :
    "${yamldecode(doc).kind}-${try(yamldecode(doc).metadata.name, uuid())}" => yamldecode(doc)

    if yamldecode(doc).kind != "Namespace"
  }
}


resource "kubernetes_namespace" "cdi" {
  metadata {
    name = "cdi"
  }
}

resource "kubernetes_manifest" "cdi_operator" {

  for_each = local.cdi_manifests

  depends_on = [
    kubernetes_namespace.cdi
  ]

  manifest = each.value

  lifecycle {
    ignore_changes = [
      object
    ]
  }
}
