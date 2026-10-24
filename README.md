# terraform-linode-kubernetes

Creates a Linode Kubernetes Engine (LKE) cluster for an environment. The `modules/platform` submodule installs the shared platform on it: ingress-nginx, cert-manager with a Let's Encrypt `ClusterIssuer`, Argo CD and n8n.

The repo name follows the `terraform-<provider>-<name>` convention that HCP Terraform's private registry requires, so it publishes as `app.terraform.io/<ORG>/kubernetes/linode`.

The cluster and the platform are meant for **separate workspaces**. The platform workspace looks the cluster up by label and configures the Kubernetes, Helm and kubectl providers from its kubeconfig. This avoids configuring providers from a resource created in the same run, and keeps the cluster's blast radius apart from the apps'.

## Usage

### Cluster

```hcl
module "kubernetes" {
  source  = "app.terraform.io/<ORG>/kubernetes/linode"
  version = "~> 1.0"

  name        = "pilot"
  environment = "dev"
  region      = "se-sto"
  node_pools  = [{ type = "g6-standard-1", count = 2 }]
}
```

### Platform

```hcl
data "linode_lke_clusters" "this" {
  filter {
    name   = "label"
    values = ["pilot-dev"]
  }
}

data "linode_lke_cluster" "this" {
  id = one(data.linode_lke_clusters.this.lke_clusters).id
}

locals {
  kube = yamldecode(base64decode(data.linode_lke_cluster.this.kubeconfig))
}

provider "kubernetes" {
  host                   = local.kube.clusters[0].cluster.server
  cluster_ca_certificate = base64decode(local.kube.clusters[0].cluster["certificate-authority-data"])
  token                  = local.kube.users[0].user.token
}
# ...and the same for provider "helm" (kubernetes = { ... }) and provider "kubectl" (plus load_config_file = false).

module "platform" {
  source  = "app.terraform.io/<ORG>/kubernetes/linode//modules/platform"
  version = "~> 1.0"

  acme_email  = "ops@example.org"
  argocd_host = "argocd.dev.example.org"
  n8n_host    = "n8n.dev.example.org"

  smtp_user     = var.smtp_user
  smtp_password = var.smtp_password
  smtp_sender   = var.smtp_sender
}
```

After the first apply, point the DNS A records for both hostnames at the `ingress_ip` output. cert-manager retries the HTTP-01 challenge until DNS resolves, then issues the certificates.

## Inputs: cluster (root module)

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | string | — | Base name; the cluster is labelled `<name>-<environment>` |
| `environment` | string | — | `dev`, `staging` or `prod` |
| `region` | string | — | Linode region ID |
| `k8s_version` | string | `"1.35"` | Kubernetes minor version |
| `node_pools` | list(object) | `[{ type = "g6-standard-1", count = 2 }]` | Plan type, node count and optional `autoscaler = { min, max }` per pool |
| `high_availability` | bool | `false` | HA control plane (extra cost) |
| `extra_tags` | list(string) | `[]` | Added to `managed-by:terraform`, `env:<environment>`, `cluster:<label>` |

## Outputs: cluster

| Name | Description |
| --- | --- |
| `cluster_id` | LKE cluster ID |
| `cluster_label` | Cluster label, used by other workspaces to look the cluster up |
| `api_endpoints` | Kubernetes API endpoints |
| `status` | Cluster status |
| `kubeconfig` | Base64 kubeconfig (sensitive) |
| `kubeconfig_command` | `linode-cli` command that writes the kubeconfig locally |

## Inputs: `modules/platform`

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `acme_email` | string | — | Let's Encrypt account email |
| `argocd_host` | string | — | Argo CD hostname |
| `n8n_host` | string | — | n8n hostname |
| `smtp_user` | string | — | SMTP login for n8n's emails |
| `smtp_password` | string (sensitive) | — | SMTP password / Brevo SMTP key |
| `smtp_sender` | string | — | Verified sender address |
| `smtp_host` | string | `"smtp-relay.brevo.com"` | SMTP relay |
| `smtp_port` | number | `2525` | Linode blocks 25/465/587 by default |
| `n8n_encryption_key` | string (sensitive) | `null` | Set to the old key when restoring an n8n database; leave null on a fresh install. Once set, keep it set |
| `n8n_persistence_size` | string | `"10Gi"` | n8n data volume (Linode minimum is 10Gi) |
| `argocd_applications` | map(object) | `{}` | Argo CD Applications: `repo_url`, `path`, `destination_namespace`, optional `target_revision`, `project`, `automated_sync` |
| `chart_versions` | object | tested pins | Override `argocd`, `cert_manager`, `ingress_nginx` or `n8n` chart versions |

## Outputs: `modules/platform`

| Name | Description |
| --- | --- |
| `ingress_ip` | NodeBalancer IP to point DNS at (empty until Linode assigns it) |
| `argocd_url` | Argo CD URL |
| `n8n_url` | n8n URL |
| `argocd_applications` | Names of the managed Argo CD Applications |

## Linode token permissions

The token both workspaces run with needs **Kubernetes: Read/Write** (the platform workspace uses it to fetch the kubeconfig). A restricted Linode user also needs the global grant to add Kubernetes clusters. NodeBalancers and Block Storage volumes are created by LKE's own controllers, not by this token.

## Testing

```bash
terraform init -backend=false && terraform test
cd modules/platform && terraform init -backend=false && terraform test
```

Both suites use mocked providers and need no Linode account or cluster.

## Releasing

Merge to `main`, then push a semver tag (`git tag v1.0.0 && git push --tags`). HCP Terraform publishes the new version automatically.

## History

This repo started as a single local root module that created the `demo-lke` cluster and its apps. That configuration is preserved on the `legacy-demo-lke` branch; it's needed only to destroy `demo-lke` after the move to HCP Terraform.
