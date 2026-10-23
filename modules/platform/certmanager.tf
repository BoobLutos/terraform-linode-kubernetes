resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.chart_versions.cert_manager

  create_namespace = true

  set = [
    {
      name  = "crds.enabled"
      value = "true"
    }
  ]
}

resource "kubectl_manifest" "letsencrypt_prod" {
  yaml_body = <<-YAML
    apiVersion: cert-manager.io/v1
    kind: ClusterIssuer
    metadata:
      name: letsencrypt-prod
    spec:
      acme:
        server: https://acme-v02.api.letsencrypt.org/directory
        email: ${var.acme_email}
        privateKeySecretRef:
          name: letsencrypt-prod
        solvers:
          - http01:
              ingress:
                ingressClassName: nginx
  YAML

  depends_on = [helm_release.cert_manager]
}
