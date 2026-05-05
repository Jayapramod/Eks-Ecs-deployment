output "namespace" {
  value = kubernetes_namespace.argocd.metadata[0].name
}

output "application_name" {
  value = "web-app"
}
