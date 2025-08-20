module "cluster" {
  source       = "./modules/cluster"
  domain       = var.domain
  cluster_name = var.cluster_name
  k8s_version  = var.k8s_version
  pod_subnet   = var.pod_subnet
  calico_ver   = var.calico_ver
}

# resource "kubernetes_namespace_v1" "default" {
#   for_each = toset(var.namespaces)

#   metadata {
#     name = each.value
#   }
#   lifecycle {
#     ignore_changes = [
#       metadata[0].annotations,
#       metadata[0].labels,
#     ]
#   }
# }

resource "flux_bootstrap_git" "this" {
  depends_on = [module.cluster]

  embedded_manifests = true
  path               = "clusters/kind_ovh"
}

# locals {
#   target_namespaces = toset(concat(
#     var.namespaces,
#     ["kube-system", "flux-system"]
#   ))
# }

# resource "kubernetes_config_map_v1" "cluster_config" {
#   for_each = local.target_namespaces
#   metadata {
#     name      = "cluster-config"
#     namespace = each.value
#   }
#   data = var.cluster_config
# }

resource "github_actions_secret" "cluster_config" {
  repository      = var.github_kind_repository
  secret_name     = "TFVARS_B64"
  plaintext_value = file("${path.module}/terraform.tfvars")
}

module "cronjob_config" {
  source         = "./modules/cron_config"
  depends_on     = [module.cluster]
  cluster_config = var.cluster_config
}