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
      api_server_address = var.domain
    }

    node {
      role = "control-plane"

      kubeadm_config_patches = [<<-YAML
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
        YAML 
      ]

      extra_port_mappings {
        container_port = 80
        host_port      = 30080
      }
      extra_port_mappings {
        container_port = 443
        host_port      = 30443
      }
    }

    node {
      role = "worker"
    }
  }
}