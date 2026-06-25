resource "helm_release" "this" {
  name       = var.name
  namespace  = var.namespace

  repository = var.repository
  chart      = var.chart
  version    = var.chart_version

  values = [
    file(var.values_file)
  ]
}
