output "namespace_name" {
  value = kubernetes_namespace.example.metadata[0].name
}

output "nginx_deployment_name" {
  value = kubernetes_deployment.nginx.metadata[0].name
}

