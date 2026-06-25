terraform {
  required_version = ">= 1.5.0"

  required_providers {
    linode = {
      source  = "linode/linode"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
  }
}

provider "linode" {
  token = var.linode_token
}

provider "kubernetes" {
  host                   = local.kube_config["clusters"][0]["cluster"]["server"]
  cluster_ca_certificate = base64decode(local.kube_config["clusters"][0]["cluster"]["certificate-authority-data"])
  token                  = local.kube_config["users"][0]["user"]["token"]
}

provider "helm" {
  kubernetes = {
    host                   = local.kube_config["clusters"][0]["cluster"]["server"]
    cluster_ca_certificate = base64decode(local.kube_config["clusters"][0]["cluster"]["certificate-authority-data"])
    token                  = local.kube_config["users"][0]["user"]["token"]
  }
}

provider "kubectl" {
  host                   = local.kube_config["clusters"][0]["cluster"]["server"]
  cluster_ca_certificate = base64decode(local.kube_config["clusters"][0]["cluster"]["certificate-authority-data"])
  token                  = local.kube_config["users"][0]["user"]["token"]
  load_config_file       = false
}
