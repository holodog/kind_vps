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
        templatefile("${path.module}/yaml/kubeadm_patch.yaml.tpl", {
          domain = var.domain
        })
      ]

      extra_port_mappings {
        container_port = 30080
        host_port      = 80
        protocol       = "TCP"
      }
      extra_port_mappings {
        container_port = 30443
        host_port      = 443
        protocol       = "TCP"
      }
      extra_port_mappings {
        container_port = 6443
        host_port      = 30444
        protocol       = "TCP"
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

resource "null_resource" "install_calico" {
  depends_on = [kind_cluster.default]

  provisioner "local-exec" {
    command = <<-EOT
      kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v${var.calico_ver}/manifests/operator-crds.yaml
      kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v${var.calico_ver}/manifests/tigera-operator.yaml
      kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v${var.calico_ver}/manifests/custom-resources.yaml
      kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v${var.calico_ver}/manifests/calico.yaml
    EOT
  }
}

# data "kubectl_path_documents" "docs" {
#     pattern = "${path.module}/yaml/calico*.yaml"
# }

# resource "kubectl_manifest" "test" {
#     for_each  = toset(data.kubectl_path_documents.docs.documents)
#     yaml_body = each.value
#     depends_on = [resource.kind_cluster.default]
# }