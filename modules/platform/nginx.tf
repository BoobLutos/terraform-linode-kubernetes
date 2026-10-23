resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  namespace  = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.chart_versions.ingress_nginx

  create_namespace = true
}

# The LoadBalancer service gets a Linode NodeBalancer from the LKE
# cloud-controller-manager; its IP is what DNS records point at.
data "kubernetes_service_v1" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = helm_release.nginx_ingress.namespace
  }
}
