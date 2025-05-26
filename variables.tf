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