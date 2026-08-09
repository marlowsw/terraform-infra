terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}
locals {

  operator_documents = [
    for doc in split("\n---", file("${path.module}/kubevirt-operator.yaml")) :
    trimspace(doc)
    if trimspace(doc) != ""
  ]

}


resource "kubernetes_namespace" "kubevirt" {

  metadata {
    name = "kubevirt"
  }

}

resource "kubernetes_service_account" "kubevirt_operator" {

  metadata {
    name      = "kubevirt-operator"
    namespace = kubernetes_namespace.kubevirt.metadata[0].name
  }

}

resource "kubernetes_manifest" "kubevirt_operator_rolebinding" {

  depends_on = [
    kubernetes_service_account.kubevirt_operator
  ]

  manifest = {
    apiVersion = "rbac.authorization.k8s.io/v1"
    kind       = "RoleBinding"

    metadata = {
      name      = "kubevirt-operator"
      namespace = "kubevirt"
    }

    roleRef = {
      apiGroup = "rbac.authorization.k8s.io"
      kind     = "Role"
      name     = "kubevirt-operator"
    }

    subjects = [
      {
        kind      = "ServiceAccount"
        name      = "kubevirt-operator"
        namespace = "kubevirt"
      }
    ]
  }
}


resource "kubernetes_manifest" "kubevirt_operator_clusterrolebinding" {

  depends_on = [
    kubernetes_service_account.kubevirt_operator
  ]

  manifest = {
    apiVersion = "rbac.authorization.k8s.io/v1"
    kind       = "ClusterRoleBinding"

    metadata = {
      name = "kubevirt-operator"
    }

    roleRef = {
      apiGroup = "rbac.authorization.k8s.io"
      kind     = "ClusterRole"
      name     = "kubevirt-operator"
    }

    subjects = [
      {
        kind      = "ServiceAccount"
        name      = "kubevirt-operator"
        namespace = "kubevirt"
      }
    ]
  }
}

#resource "kubernetes_manifest" "kubevirt_operator" {
#
#  for_each = {
#    for doc in local.operator_documents :
#    "${yamldecode(doc).kind}-${try(yamldecode(doc).metadata.name, "unknown")}" => doc
#
#    if !can(regex("kind: Namespace", doc))
#    && !can(regex("kind: PriorityClass", doc))
#    && !can(regex("kind: ServiceAccount", doc))
#  }
#
#  depends_on = [
#    kubernetes_namespace.kubevirt,
#    kubernetes_service_account.kubevirt_operator
#  ]
#
#  manifest = yamldecode(each.value)
#
#  lifecycle {
#    ignore_changes = [
#      object
#    ]
#  }
#}

resource "kubernetes_manifest" "kubevirt_cr" {

  depends_on = [
    kubernetes_namespace.kubevirt,
    kubernetes_service_account.kubevirt_operator
  ]

  manifest = yamldecode(
    file("${path.module}/kubevirt-cr.yaml")
  )

}
