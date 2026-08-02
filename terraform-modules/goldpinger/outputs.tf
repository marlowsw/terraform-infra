output "namespace" {
  value = kubernetes_namespace_v1.goldpinger.metadata[0].name
}


output "service" {
  value = kubernetes_service_v1.goldpinger.metadata[0].name
}


output "node_port" {
  value = kubernetes_service_v1.goldpinger.spec[0].port[0].node_port
}
