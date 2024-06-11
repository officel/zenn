# Argo CD on kind by terraform

- [terraform で kind cluster を管理](https://zenn.dev/terraform_jp/articles/2024-05-20_terraform_kind)
- [ingress-nginx を追加](https://zenn.dev/terraform_jp/articles/2024-06-07_terraform_kind_ingress_nginx)
- 今回は [Argo CD](https://argo-cd.readthedocs.io/) を動かしてアプリケーションを動かすところまで
- Argo CD CLI は別途インストールしておくこと（[aqua で楽できる](https://zenn.dev/raki/articles/2024-05-16_aqua)）

## 前回（../2024-06_kind_ingress_nginx/）からの変更点と作業メモ

- use helm_release resource for argocd
- provider.tf の source は書いて version は外した（常に最新を使っておいて問題が出たら指定するなり直すなり）
- 同じようなところのコメントは省略

```bash
terraform init
terraform plan
terraform apply

direnv allow
docker ps
kubectl get node -o wide
kubectl get all -A

# Argo CD の分だけ
kubectl get all -n argocd

# admin ユーザの初期パスワードを取得
argocd admin initial-password -n argocd
```

### port-forward で接続

ドキュメントのとおり port-forward でアクセスさせてみる（正直毎回こんなの打ちたくない）

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
# ブラウザで https://localhost:8080/ にアクセス
# 説明の必要はないと思うけど fg して ctrl+c で port-forward を停止
# もしくは jobs -l してプロセス番号を確認して kill
```

### ingress-nginx で接続

ingress-nginx でアクセスできるようにする

- 名前解決をしておく（argocd.local をローカルホストに向ければだいたい問題ない）
  - 外部のDNSを使うなり
  - hosts を使うなり
  - [Windows で hosts をいじるのに専用のエディタ](https://x.com/raki/status/1799193332805140695) があって便利
- IPv6 を docker や kind の ingress で処理していないので IPv4 でアクセスする（hostsのIPv6を使わない）
- cert-manager を入れて SSL 終端も処理しようと思っていたけど、今のところそこにこだわってないので後回しにした

```bash
# 手打ちしても構わない場合
kubectl apply -f ingress_argocd.yaml
# ブラウザで https://argocd.local/ に接続。SSLは一旦無視


# 手打ちはめんどくさい場合
export TF_VAR_ingress_argocd=true
# ドメインを変更したい場合（好きなように）
export TF_VAR_domain_argocd="ci.my.local"
terraform apply
```
