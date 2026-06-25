variable "linode_token" {
  description = "Linode API token"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Linode region (e.g. us-east, eu-west, ap-south)"
  type        = string
  default     = "us-east"
}

variable "cluster_name" {
  description = "LKE cluster name"
  type        = string
  default     = "demo-lke"
}
