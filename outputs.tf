output "cluster_id" {
  description = "ID of the LKE cluster."
  value       = linode_lke_cluster.this.id
}

output "cluster_label" {
  description = "Label of the LKE cluster. Other workspaces look the cluster up by this label."
  value       = linode_lke_cluster.this.label
}

output "api_endpoints" {
  description = "Kubernetes API endpoints of the cluster."
  value       = linode_lke_cluster.this.api_endpoints
}

output "status" {
  description = "Status of the cluster."
  value       = linode_lke_cluster.this.status
}

output "kubeconfig" {
  description = "Base64-encoded kubeconfig for the cluster."
  value       = linode_lke_cluster.this.kubeconfig
  sensitive   = true
}

output "kubeconfig_command" {
  description = "Command that writes this cluster's kubeconfig to ~/.kube/<label>.yaml."
  value       = "linode-cli lke kubeconfig-view ${linode_lke_cluster.this.id} --json | jq -r '.[0].kubeconfig' | base64 -d > ~/.kube/${linode_lke_cluster.this.label}.yaml"
}
