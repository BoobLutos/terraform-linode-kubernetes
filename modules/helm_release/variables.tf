variable "name" {
  type        = string
  description = "Helm release name"
}

variable "namespace" {
  type        = string
  default     = "default"
}

variable "repository" {
  type        = string
  description = "Helm chart repository URL"
}

variable "chart" {
  type        = string
  description = "Helm chart name"
}

variable "chart_version" {
  type        = string
  description = "Helm chart version"
}

variable "values_file" {
  type        = string
  description = "Path to a values.yaml file"
}
