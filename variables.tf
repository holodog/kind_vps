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