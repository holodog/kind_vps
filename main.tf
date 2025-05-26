module "cluster" {
  source       = "./modules/cluster"
  domain       = var.domain
  cluster_name = var.cluster_name
  k8s_version  = var.k8s_version
  pod_subnet   = var.pod_subnet
  calico_ver = var.calico_ver
}