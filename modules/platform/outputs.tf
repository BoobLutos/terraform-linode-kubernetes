output "ingress_ip" {
  description = "Public IPv4 of the ingress NodeBalancer. Point the argocd_host and n8n_host DNS A records here. Empty until Linode assigns it; the next run fills it in."
  value       = try(data.kubernetes_service_v1.ingress_nginx.status[0].load_balancer[0].ingress[0].ip, "")
}

output "argocd_url" {
  description = "URL of the Argo CD UI. The initial admin password is in the argocd-initial-admin-secret secret."
  value       = "https://${var.argocd_host}"
}

output "n8n_url" {
  description = "URL of n8n."
  value       = "https://${var.n8n_host}"
}

output "argocd_applications" {
  description = "Names of the Argo CD Applications this module manages."
  value       = keys(var.argocd_applications)
}
