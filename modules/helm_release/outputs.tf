output "name" {
  value = helm_release.this.name
}

output "namespace" {
  value = helm_release.this.namespace
}

output "status" {
  value = helm_release.this.status
}
