resource "kind_cluster" "this" {
  name           = local.name
  wait_for_ready = true

  # 設定を出力する場所をローカルに固定する
  kubeconfig_path = pathexpand(local.kind_cluster_config_path)

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      kubeadm_config_patches = [
        #"kind: InitConfiguration\nnodeRegistration:\n  kubeletExtraArgs:\n    node-labels: \"ingress-ready=true\"\n"
        # 今後追加しやすいように外部ファイル化
        file("${path.module}/kind_kubeadm_config_patchs.yaml")
      ]

      extra_port_mappings {
        container_port = 80
        host_port      = 80
      }
      extra_port_mappings {
        container_port = 443
        host_port      = 443
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
