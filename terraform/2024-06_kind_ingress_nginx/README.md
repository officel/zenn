# ingress-nginx on kind by terraform

[kind – Ingress](https://kind.sigs.k8s.io/docs/user/ingress/)

- terraform で kind cluster を管理（前回済）
- ingress-nginx を追加
- サンプルを動かすところまで

## 前回（../2024-05_kind/）からの変更点と作業メモ

- rename providers.tf
- `diff kind_cluster.tf ../2024-05_kind/kind_cluster.tf`
  - use kubeconfig_path (.kube_config)
  - use file() function
- use helm_release resource for ingress-nginx

```bash
# いつでも最新に
terraform init

# 変更点を確認して
terraform plan

# 適用すればOK。ingress pod が起動するのを待つ処理も書けるけどなくても困らない
terraform apply

# 新しく kind cluster ができたら流しておけば
direnv allow

# docker container として cluster ができている
docker ps

# ノードを確認
kubectl get node -o wide

# 出来上がってる k8s リソースを確認（all以外のチェックもやってみたらいい）
kubectl get all -A

# サンプルのアプリケーションを展開
kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/usage.yaml

# localhost はエラーになるけど、パスで振り分ける処理はちゃんと動いている（サンプル確認）
curl localhost
curl localhost/foo/hostname
curl localhost/bar/hostname
```
