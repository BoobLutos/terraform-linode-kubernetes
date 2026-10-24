variable "acme_email" {
  description = "Email Let's Encrypt sends certificate expiry notices to."
  type        = string
}

variable "argocd_host" {
  description = "Public hostname for the Argo CD UI, e.g. argocd.example.org. Its DNS A record must point at the ingress_ip output."
  type        = string
}

variable "n8n_host" {
  description = "Public hostname for n8n, e.g. n8n.example.org. Its DNS A record must point at the ingress_ip output."
  type        = string
}

variable "argocd_applications" {
  description = "Argo CD Applications to create, keyed by application name. Each syncs a path of a Git repo into a namespace."
  type = map(object({
    repo_url              = string
    path                  = string
    target_revision       = optional(string, "HEAD")
    destination_namespace = string
    project               = optional(string, "default")
    automated_sync        = optional(bool, true)
  }))
  default = {}
}

variable "n8n_persistence_size" {
  description = "Size of n8n's data volume. Linode Block Storage has a 10Gi minimum."
  type        = string
  default     = "10Gi"
}

variable "n8n_encryption_key" {
  description = "Key n8n encrypts stored credentials with, stored in the n8n-encryption-key secret. Leave null to let the chart generate one. Set it to the old key when restoring an existing n8n database, and keep it set afterwards: removing it makes the chart generate a new key."
  type        = string
  default     = null
  sensitive   = true
}

variable "smtp_host" {
  description = "SMTP relay n8n sends password-reset emails through."
  type        = string
  default     = "smtp-relay.brevo.com"
}

variable "smtp_port" {
  description = "SMTP port. Linode blocks outbound 25/465/587 by default; Brevo's relay also listens on 2525."
  type        = number
  default     = 2525
}

variable "smtp_user" {
  description = "SMTP login (for Brevo, usually the account email)."
  type        = string
}

variable "smtp_password" {
  description = "SMTP password (for Brevo, the SMTP key from SMTP & API > SMTP, not the REST API key)."
  type        = string
  sensitive   = true
}

variable "smtp_sender" {
  description = "Verified sender address n8n's emails are sent from."
  type        = string
}

variable "chart_versions" {
  description = "Helm chart versions. Override one key at a time; unset keys keep the tested default."
  type = object({
    argocd        = optional(string, "6.7.12")
    cert_manager  = optional(string, "v1.20.3")
    ingress_nginx = optional(string, "4.10.1")
    n8n           = optional(string, "1.24.0")
  })
  default = {}
}
