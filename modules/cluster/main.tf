locals {
  k8s_config_path = pathexpand("~/home/kind.config")
}

resource "kind_cluster" "default" {
  name            = var.cluster_name
  wait_for_ready  = true
  kubeconfig_path = local.k8s_config_path
  node_image      = "kindest/node:v${var.k8s_version}"

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    networking {
      api_server_address  = "0.0.0.0"
      disable_default_cni = var.pod_subnet != ""
      pod_subnet          = var.pod_subnet
    }

    node {
      role = "control-plane"

      kubeadm_config_patches = [
        templatefile("${path.module}/kubeadm_patch.yaml.tpl", {
          domain = var.domain
        })
      ]

      extra_port_mappings {
        container_port = 80
        host_port      = 30080
      }
      extra_port_mappings {
        container_port = 443
        host_port      = 30443
      }
      extra_port_mappings {
        container_port = 6443
        host_port      = 30444
      }
    }

    node {
      role = "worker"
    }
    node {
      role = "worker"
    }
  }
}
