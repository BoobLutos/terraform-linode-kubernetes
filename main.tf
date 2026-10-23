# -------------------------
# LKE CLUSTER
# -------------------------
resource "linode_lke_cluster" "this" {
  label       = var.cluster_name
  k8s_version = "1.35"
  region      = var.region

  pool {
    type  = "g6-standard-1"
    count = 2
  }

  tags = [var.cluster_name]
}

locals {
  kube_config = yamldecode(base64decode(linode_lke_cluster.this.kubeconfig))
}

# -------------------------
# HELM MODULE
# -------------------------
module "helm" {
  source = "./helm"

  brevo_smtp_login = var.brevo_smtp_login
  brevo_smtp_key   = var.brevo_smtp_key
  n8n_smtp_sender  = var.n8n_smtp_sender

  providers = {
    kubernetes = kubernetes
    helm       = helm
    kubectl    = kubectl
    random     = random
  }
}
