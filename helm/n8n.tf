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
  version    = "1.24.0"

  create_namespace = false

  timeout = 600

  set = [
    {
      name  = "main.persistence.enabled"
      value = "true"
    },
    {
      name  = "main.persistence.size"
      value = "5Gi"
    },
    {
      name  = "strategy.type"
      value = "Recreate"
    },
    {
      name  = "main.editorBaseUrl"
      value = "https://n8n.sinza.org"
    },
    {
      name  = "webhook.url"
      value = "https://n8n.sinza.org"
    },
    {
      name  = "main.extraEnvVars.N8N_HOST"
      value = "n8n.sinza.org"
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
      value = "smtp-relay.brevo.com"
    },
    {
      # Linode blocks outbound 25/465/587 by default (anti-spam policy); Brevo's
      # relay also listens on 2525, which isn't blocked.
      name  = "main.extraEnvVars.N8N_SMTP_PORT"
      value = "2525"
    },
    {
      # STARTTLS on 2525, not implicit TLS — leave false per Brevo's relay requirements.
      name  = "main.extraEnvVars.N8N_SMTP_SSL"
      value = "false"
    },
    {
      name  = "main.extraEnvVars.N8N_SMTP_USER"
      value = var.brevo_smtp_login
    },
    {
      name  = "main.extraEnvVars.N8N_SMTP_SENDER"
      value = var.n8n_smtp_sender
    }
  ]

  set_sensitive = [
    {
      name  = "main.extraEnvVars.N8N_SMTP_PASS"
      value = var.brevo_smtp_key
    }
  ]

  depends_on = [kubernetes_namespace_v1.n8n, helm_release.nginx_ingress]
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
      hosts       = ["n8n.sinza.org"]
      secret_name = "n8n-tls"
    }

    rule {
      host = "n8n.sinza.org"

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
