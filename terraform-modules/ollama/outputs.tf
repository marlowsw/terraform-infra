output "openwebui_url" {
  description = "Open WebUI login URL"
  value       = "http://10.0.0.34:${var.openwebui_nodeport}"
}

output "ollama_url" {
  description = "Ollama API URL"
  value       = "http://10.0.0.34:${var.ollama_nodeport}"
}

output "namespace" {
  value = kubernetes_namespace.ollama.metadata[0].name
}

output "ollama_pvc" {
  value = kubernetes_persistent_volume_claim.ollama.metadata[0].name
}

output "openwebui_pvc" {
  value = kubernetes_persistent_volume_claim.openwebui.metadata[0].name
}
