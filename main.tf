locals {
  label = "${var.name}-${var.environment}"

  tags = distinct(concat(
    ["managed-by:terraform", "env:${var.environment}", "cluster:${local.label}"],
    var.extra_tags,
  ))
}

resource "linode_lke_cluster" "this" {
  label       = local.label
  k8s_version = var.k8s_version
  region      = var.region
  tags        = local.tags

  control_plane {
    high_availability = var.high_availability
  }

  dynamic "pool" {
    for_each = var.node_pools

    content {
      type  = pool.value.type
      count = pool.value.count
      tags  = local.tags

      dynamic "autoscaler" {
        for_each = pool.value.autoscaler == null ? [] : [pool.value.autoscaler]

        content {
          min = autoscaler.value.min
          max = autoscaler.value.max
        }
      }
    }
  }
}
