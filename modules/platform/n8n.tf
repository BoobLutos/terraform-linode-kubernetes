resource "kubernetes_namespace_v1" "n8n" {
  metadata {
    name = "n8n"
  }
}

resource "helm_release" "n8n" {
  name       = "n8n"
  namespace  = kubernetes_namespace_v1.n8n.metadata[0].name
  repository = "https://community-charts.github.io/helm-charts"
  chart      = "n8n"
  version    = var.chart_versions.n8n

  timeout = 600

  set = concat(
    [
      {
        name  = "main.persistence.enabled"
        value = "true"
      },
      {
        name  = "main.persistence.size"
        value = var.n8n_persistence_size
      },
      {
        # The data volume is ReadWriteOnce; a rolling update would deadlock on it.
        name  = "strategy.type"
        value = "Recreate"
      },
      {
        name  = "main.editorBaseUrl"
        value = "https://${var.n8n_host}"
      },
      {
        name  = "webhook.url"
        value = "https://${var.n8n_host}"
      },
      {
        name  = "main.extraEnvVars.N8N_HOST"
        value = var.n8n_host
      },
      {
        name  = "main.extraEnvVars.N8N_PROTOCOL"
        value = "https"
      },
      {
        name  = "main.extraEnvVars.N8N_EMAIL_MODE"
        value = "smtp"
      },
      {
        name  = "main.extraEnvVars.N8N_SMTP_HOST"
        value = var.smtp_host
      },
      {
        name  = "main.extraEnvVars.N8N_SMTP_PORT"
        value = tostring(var.smtp_port)
      },
      {
        # STARTTLS on 2525, not implicit TLS, per Brevo's relay requirements.
        name  = "main.extraEnvVars.N8N_SMTP_SSL"
        value = "false"
      },
      {
        name  = "main.extraEnvVars.N8N_SMTP_USER"
        value = var.smtp_user
      },
      {
        name  = "main.extraEnvVars.N8N_SMTP_SENDER"
        value = var.smtp_sender
      }
    ],
    # The chart's encryptionKey value is ignored once its own key secret
    # exists (it reuses that secret on upgrade), so pass our own secret instead.
    var.n8n_encryption_key == null ? [] : [
      {
        name  = "existingEncryptionKeySecret"
        value = kubernetes_secret_v1.n8n_encryption_key[0].metadata[0].name
      }
    ],
  )

  set_sensitive = [
    {
      name  = "main.extraEnvVars.N8N_SMTP_PASS"
      value = var.smtp_password
    }
  ]

  depends_on = [helm_release.nginx_ingress]
}

resource "kubernetes_secret_v1" "n8n_encryption_key" {
  count = var.n8n_encryption_key == null ? 0 : 1

  metadata {
    name      = "n8n-encryption-key"
    namespace = kubernetes_namespace_v1.n8n.metadata[0].name
  }

  data = {
    N8N_ENCRYPTION_KEY = var.n8n_encryption_key
  }
}

resource "kubernetes_ingress_v1" "n8n" {
  metadata {
    name      = "n8n"
    namespace = kubernetes_namespace_v1.n8n.metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
      "cert-manager.io/cluster-issuer"               = "letsencrypt-prod"
    }
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = [var.n8n_host]
      secret_name = "n8n-tls"
    }

    rule {
      host = var.n8n_host

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "n8n"
              port {
                number = 5678
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.n8n, kubectl_manifest.letsencrypt_prod]
}
