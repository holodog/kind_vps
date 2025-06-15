variable "domain" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "k8s_version" {
  type = string
}

variable "pod_subnet" {
  type    = string
  default = ""
}

variable "calico_ver" {
  type = string
}

variable "cluster_config" {
  description = "Cluster config as a key-value map"
  type        = map(string)
}

variable "github_org" {
  description = "GitHub Org/User name"
  type        = string
}

variable "github_flux_repository" {
  description = "GitHub repository for FLUX deployments"
  type        = string
}

variable "github_kind_repository" {
  description = "GitHub repository for KIND cluster"
  type        = string
}

variable "github_token" {
  description = "GitHub Personal Access Token"
  type        = string
}

variable "namespaces" {
  description = "Namespaces to be spinned up by default"
  type        = list(string)
  default     = ["monitoring", "ingress"]
}