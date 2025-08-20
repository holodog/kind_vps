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

resource "kubernetes_cluster_role_v1" "cluster_config_writer" {
  metadata {
    name = "cluster-config-writer"
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps", "namespaces"]
    verbs      = ["get", "list", "create", "update", "patch", "delete"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "cluster_config_writer_binding" {
  metadata {
    name = "cluster-config-writer-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.cluster_config_writer.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.configmap_sync.metadata[0].name
    namespace = "kube-system"
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
                set -e
                echo "Fetching base configmap from kube-system..."
                kubectl get configmap cluster-config -n kube-system -o yaml > /tmp/base.yaml

                for ns in $(kubectl get ns -o jsonpath="{.items[*].metadata.name}"); do
                  if [[ "$ns" == "kube-system" ]]; then continue; fi

                  echo "Syncing configmap to namespace: $ns"
                  
                  # sanitize and patch namespace
                  cat /tmp/base.yaml | \
                    yq e 'del(.metadata.namespace)' - | \
                    yq e 'del(.metadata.resourceVersion)' - | \
                    yq e 'del(.metadata.uid)' - | \
                    yq e 'del(.metadata.creationTimestamp)' - | \
                    yq e '.metadata.namespace = strenv(ns)' - > /tmp/cleaned.yaml

                  kubectl -n "$ns" apply -f /tmp/cleaned.yaml
                done
              EOT
              ]
              env {
                name = "ns"
                value_from {
                  field_ref {
                    field_path = "metadata.namespace"
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
