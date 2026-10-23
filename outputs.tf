output "cluster_name" {
  value = linode_lke_cluster.this.label
}

output "cluster_id" {
  value = linode_lke_cluster.this.id
}

output "cluster_status" {
  value = linode_lke_cluster.this.status
}

output "kubeconfig_command" {
  description = "Command to download and merge the LKE kubeconfig"
  value       = "linode-cli lke kubeconfig-view ${linode_lke_cluster.this.id} --json | jq -r '.[0].kubeconfig' | base64 -d > ~/.kube/config"
}
