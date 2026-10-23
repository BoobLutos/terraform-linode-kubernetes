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

variable "brevo_smtp_login" {
  description = "Brevo SMTP login (usually the Brevo account email), used for n8n's forgot-password emails"
  type        = string
}

variable "brevo_smtp_key" {
  description = "Brevo SMTP key (from SMTP & API > SMTP tab, not the REST API key), used for n8n's forgot-password emails"
  type        = string
  sensitive   = true
}

variable "n8n_smtp_sender" {
  description = "Verified sender address n8n's password-reset emails will be sent from"
  type        = string
}
