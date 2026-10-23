resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace_v1.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_versions.argocd

  set = [
    {
      name  = "dex.enabled"
      value = "false"
    },
    {
      # TLS terminates at ingress-nginx.
      name  = "configs.params.server\\.insecure"
      value = "true"
    }
  ]
}

resource "kubernetes_ingress_v1" "argocd" {
  metadata {
    name      = "argocd-server"
    namespace = kubernetes_namespace_v1.argocd.metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
      "cert-manager.io/cluster-issuer"               = "letsencrypt-prod"
    }
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = [var.argocd_host]
      secret_name = "argocd-tls"
    }

    rule {
      host = var.argocd_host

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "argocd-server"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.argocd, helm_release.nginx_ingress, kubectl_manifest.letsencrypt_prod]
}

resource "kubectl_manifest" "argocd_application" {
  for_each = var.argocd_applications

  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = each.key
      namespace = kubernetes_namespace_v1.argocd.metadata[0].name
    }
    spec = merge(
      {
        project = each.value.project
        source = {
          repoURL        = each.value.repo_url
          path           = each.value.path
          targetRevision = each.value.target_revision
        }
        destination = {
          server    = "https://kubernetes.default.svc"
          namespace = each.value.destination_namespace
        }
      },
      each.value.automated_sync ? {
        syncPolicy = {
          automated   = { prune = true, selfHeal = true }
          syncOptions = ["CreateNamespace=true"]
        }
      } : {},
    )
  })

  depends_on = [helm_release.argocd]
}
