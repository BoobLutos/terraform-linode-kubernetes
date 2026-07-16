output "kafka_sasl_username" {
  description = "Username for the Kafka SASL/PLAIN client listener"
  value       = local.kafka_sasl_username
}

output "kafka_sasl_password" {
  description = "Password for the Kafka SASL/PLAIN client listener"
  value       = random_password.kafka_sasl.result
  sensitive   = true
}

output "kafka_ui_admin_username" {
  description = "Login username for Kafka UI at https://kafka.sinza.org"
  value       = local.kafka_ui_admin_user
}

output "kafka_ui_admin_password" {
  description = "Login password for Kafka UI at https://kafka.sinza.org"
  value       = random_password.kafka_ui_admin.result
  sensitive   = true
}
