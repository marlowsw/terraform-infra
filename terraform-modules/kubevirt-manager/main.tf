terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}
locals {
  kubevirt_manager_documents = [
    for doc in split("\n---", file("${path.module}/kubevirt-manager.yaml")) :
    trimspace(doc)
    if trimspace(doc) != ""
    && can(yamldecode(doc))
  ]

  kubevirt_manager_manifests = {
    for doc in local.kubevirt_manager_documents :
    "${yamldecode(doc).kind}-${try(yamldecode(doc).metadata.name, uuid())}" => yamldecode(doc)

    if yamldecode(doc).kind != "Namespace"
  }
}


resource "kubernetes_namespace" "kubevirt_manager" {

  metadata {
    name = "kubevirt-manager"
  }

}


resource "kubernetes_manifest" "kubevirt_manager" {

  for_each = local.kubevirt_manager_manifests

  depends_on = [
    kubernetes_namespace.kubevirt_manager
  ]

  manifest = each.value

  lifecycle {
    ignore_changes = [
      object
    ]
  }

}
