output "namespace" {
  value = kubernetes_namespace.argocd.metadata[0].name
}

output "argocd_url" {
  value = "https://${var.argocd_hostname}"
}
