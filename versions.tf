terraform {
  required_version = ">= 1.10"

  required_providers {
    linode = {
      source  = "linode/linode"
      version = ">= 4.7, < 5.0"
    }
  }
}
