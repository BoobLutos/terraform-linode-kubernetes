terraform {
  required_version = ">= 1.10"

  # The caller configures these providers against the target cluster, e.g. from
  # the linode_lke_cluster data source's kubeconfig.
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 3.0, < 4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.0, < 4.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14, < 2.0"
    }
  }
}
