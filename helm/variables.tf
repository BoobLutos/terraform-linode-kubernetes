# No variables required — Linode NodeBalancers are provisioned automatically
# by the LKE cloud-controller-manager when a LoadBalancer service is created.

variable "brevo_smtp_login" {
  description = "Brevo SMTP login, used for n8n's forgot-password emails"
  type        = string
}

variable "brevo_smtp_key" {
  description = "Brevo SMTP key, used for n8n's forgot-password emails"
  type        = string
  sensitive   = true
}

variable "n8n_smtp_sender" {
  description = "Verified sender address n8n's password-reset emails will be sent from"
  type        = string
}
