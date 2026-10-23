# Unit tests that run without a Linode account: the provider is mocked.
# Run with: terraform test

mock_provider "linode" {
  # Linode IDs are numeric; the default mock values are random text.
  mock_resource "linode_lke_cluster" {
    defaults = {
      id = "623634"
    }
  }
}

variables {
  name        = "pilot"
  environment = "dev"
  region      = "se-sto"
}

run "defaults" {
  command = plan

  assert {
    condition     = linode_lke_cluster.this.label == "pilot-dev"
    error_message = "Cluster label should be <name>-<environment>."
  }

  assert {
    condition     = linode_lke_cluster.this.k8s_version == "1.35"
    error_message = "Default k8s_version should be 1.35."
  }

  assert {
    condition     = length(linode_lke_cluster.this.pool) == 1 && linode_lke_cluster.this.pool[0].type == "g6-standard-1" && linode_lke_cluster.this.pool[0].count == 2
    error_message = "Default should be one pool of 2 x g6-standard-1."
  }

  assert {
    condition     = contains(linode_lke_cluster.this.tags, "managed-by:terraform") && contains(linode_lke_cluster.this.tags, "env:dev")
    error_message = "Cluster must carry the managed-by:terraform and env:<environment> tags."
  }
}

run "autoscaled_pool_and_extra_tags" {
  command = plan

  variables {
    node_pools = [
      { type = "g6-standard-2", count = 3, autoscaler = { min = 3, max = 5 } },
    ]
    extra_tags = ["owner:platform-team", "env:dev"]
  }

  assert {
    condition     = linode_lke_cluster.this.pool[0].autoscaler[0].max == 5
    error_message = "Autoscaler settings not passed through."
  }

  assert {
    condition     = length([for t in linode_lke_cluster.this.tags : t if t == "env:dev"]) == 1
    error_message = "Duplicate tags should be removed."
  }
}

run "rejects_bad_k8s_version" {
  command = plan

  variables {
    k8s_version = "1.35.2"
  }

  expect_failures = [var.k8s_version]
}

run "rejects_unknown_environment" {
  command = plan

  variables {
    environment = "qa"
  }

  expect_failures = [var.environment]
}
