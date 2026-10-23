# Unit tests with mocked Kubernetes, Helm and kubectl providers, so no cluster
# is needed. Run from modules/platform with: terraform test

mock_provider "kubernetes" {}
mock_provider "helm" {}
mock_provider "kubectl" {}

variables {
  acme_email    = "ops@example.org"
  argocd_host   = "argocd.dev.example.org"
  n8n_host      = "n8n.dev.example.org"
  smtp_user     = "ops@example.org"
  smtp_password = "not-a-real-key"
  smtp_sender   = "n8n@example.org"
}

run "hostnames_wired_through" {
  command = plan

  assert {
    condition     = kubernetes_ingress_v1.argocd.spec[0].rule[0].host == "argocd.dev.example.org"
    error_message = "Argo CD ingress host not set from argocd_host."
  }

  assert {
    condition     = tolist(kubernetes_ingress_v1.n8n.spec[0].tls[0].hosts) == tolist(["n8n.dev.example.org"])
    error_message = "n8n TLS host not set from n8n_host."
  }

  assert {
    condition     = one([for s in helm_release.n8n.set : s.value if s.name == "webhook.url"]) == "https://n8n.dev.example.org"
    error_message = "n8n webhook URL should be https://<n8n_host>."
  }

  assert {
    condition     = strcontains(kubectl_manifest.letsencrypt_prod.yaml_body, "email: ops@example.org")
    error_message = "ACME email not set on the ClusterIssuer."
  }

  assert {
    condition     = length(helm_release.n8n.set_sensitive) == 1
    error_message = "Without n8n_encryption_key only the SMTP password should be a sensitive value."
  }

  assert {
    condition     = length(kubectl_manifest.argocd_application) == 0
    error_message = "No Argo CD Applications by default."
  }
}

run "restore_key_and_applications" {
  command = plan

  variables {
    n8n_encryption_key = "old-key"
    argocd_applications = {
      demo = {
        repo_url              = "https://github.com/example/manifests.git"
        path                  = "apps/demo"
        destination_namespace = "demo"
      }
    }
  }

  assert {
    condition     = contains([for s in helm_release.n8n.set_sensitive : s.name], "encryptionKey")
    error_message = "n8n_encryption_key should set the chart's encryptionKey."
  }

  assert {
    condition     = yamldecode(kubectl_manifest.argocd_application["demo"].yaml_body).spec.source.path == "apps/demo"
    error_message = "Argo CD Application path not passed through."
  }

  assert {
    condition     = yamldecode(kubectl_manifest.argocd_application["demo"].yaml_body).spec.syncPolicy.automated.selfHeal
    error_message = "Automated sync should be on by default."
  }
}
