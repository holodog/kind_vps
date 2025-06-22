resource "kubernetes_config_map_v1" "cluster_config" {
  metadata {
    name      = "cluster-config"
    namespace = "kube-system"
  }
  data = var.cluster_config
}

resource "kubernetes_service_account_v1" "configmap_sync" {
  metadata {
    name      = "cluster-config-writer"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_v1" "configmap_manager" {
  metadata {
    name = "cluster-config-writer"
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces", "configmaps"]
    verbs      = ["get", "list", "create", "update"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "configmap_binding" {
  metadata {
    name = "cluster-config-writer-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.configmap_manager.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.configmap_sync.metadata[0].name
    namespace = kubernetes_service_account_v1.configmap_sync.metadata[0].namespace
  }
}

resource "kubernetes_cron_job_v1" "cluster_config_sync" {
  metadata {
    name      = "cluster-config-sync"
    namespace = "kube-system"
  }

  spec {
    schedule = "*/15 * * * *"
    job_template {
      metadata {
        name = "cluster-config-job"
      }

      spec {
        template {
          metadata {
            labels = {
              job = "cluster-config-sync"
            }
          }

          spec {
            service_account_name = kubernetes_service_account_v1.configmap_sync.metadata[0].name
            restart_policy       = "OnFailure"

            container {
              name    = "sync"
              image   = "bitnami/kubectl:latest"
              command = ["/bin/bash", "-c"]
              args = [<<-EOT
                hostname=$(kubectl get configmap cluster-config -n kube-system -o jsonpath="{.data.hostname}")
                gf_ingress=$(kubectl get configmap cluster-config -n kube-system -o jsonpath="{.data.gf_ingress}")
                for ns in $(kubectl get ns -o jsonpath="{.items[*].metadata.name}"); do
                  if [[ "$ns" == "kube-system" ]]; then continue; fi
                  if kubectl get configmap cluster-config -n $ns >/dev/null 2>&1; then
                    echo "Updating configmap in $ns"
                    kubectl delete configmap cluster-config -n $ns
                  fi
                  echo "Creating configmap in $ns"
                  kubectl create configmap cluster-config \
                    --from-literal=hostname=$hostname \
                    --from-literal=gf_ingress="$gf_ingress" \
                    -n $ns
                done
              EOT
              ]
            }
          }
        }
      }
    }
  }
}
