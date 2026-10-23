variable "name" {
  description = "Base name for the cluster. The environment is appended, e.g. \"pilot\" becomes \"pilot-dev\"."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{3,28}$", var.name))
    error_message = "name must be 3-28 characters: lowercase letters, digits and hyphens."
  }
}

variable "environment" {
  description = "Environment name (dev, staging or prod)."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "region" {
  description = "Linode region ID, e.g. se-sto (Stockholm) or eu-central (Frankfurt)."
  type        = string
}

variable "k8s_version" {
  description = "Kubernetes minor version, e.g. \"1.35\". See `linode-cli lke versions-list`."
  type        = string
  default     = "1.35"

  validation {
    condition     = can(regex("^1\\.[0-9]+$", var.k8s_version))
    error_message = "k8s_version must be a minor version such as \"1.35\"."
  }
}

variable "node_pools" {
  description = "Node pools. Each needs a Linode plan type and node count; set autoscaler to let LKE scale between min and max."
  type = list(object({
    type  = string
    count = number
    autoscaler = optional(object({
      min = number
      max = number
    }))
  }))
  default = [
    { type = "g6-standard-1", count = 2 },
  ]

  validation {
    condition     = length(var.node_pools) > 0
    error_message = "At least one node pool is required."
  }

  validation {
    condition     = alltrue([for p in var.node_pools : p.count >= 1])
    error_message = "Every node pool needs count >= 1."
  }
}

variable "high_availability" {
  description = "Run a highly available control plane (extra monthly cost)."
  type        = bool
  default     = false
}

variable "extra_tags" {
  description = "Tags added to the cluster and its nodes, on top of managed-by:terraform, env:<environment> and cluster:<label>."
  type        = list(string)
  default     = []
}
