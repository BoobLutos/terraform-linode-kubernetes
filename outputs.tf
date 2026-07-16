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

output "kafka_sasl_username" {
  description = "Username for the Kafka SASL/PLAIN client listener"
  value       = module.helm.kafka_sasl_username
}

output "kafka_sasl_password" {
  description = "Password for the Kafka SASL/PLAIN client listener"
  value       = module.helm.kafka_sasl_password
  sensitive   = true
}

output "kafka_ui_admin_username" {
  description = "Login username for Kafka UI at https://kafka.sinza.org"
  value       = module.helm.kafka_ui_admin_username
}

output "kafka_ui_admin_password" {
  description = "Login password for Kafka UI at https://kafka.sinza.org"
  value       = module.helm.kafka_ui_admin_password
  sensitive   = true
}
