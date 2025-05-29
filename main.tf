module "cluster" {
  source       = "./modules/cluster"
  domain       = var.domain
  cluster_name = var.cluster_name
  k8s_version  = var.k8s_version
  pod_subnet   = var.pod_subnet
  calico_ver   = var.calico_ver
}

data "kubernetes_all_namespaces" "allns" {}

resource "kubernetes_config_map" "cluster_config" {
  for_each = {
    for ns in data.kubernetes_all_namespaces.allns.namespaces :
    ns => ns
  }

  metadata {
    name      = "cluster-config"
    namespace = each.key
  }

  data = var.cluster_config
}