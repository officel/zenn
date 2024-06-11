locals {
  name = "my-kind"

  # global を巻き込まずにこのディレクトリでだけ使うように固定する
  # direnv(.envrc) を使用して、自動的にコンテキストを変更する
  # cat .envrc
  # export KUBECONFIG=$(pwd)/.kube_config
  kind_cluster_config_path = ".kube_config"
}
