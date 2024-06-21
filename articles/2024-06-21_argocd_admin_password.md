---
title: "Argo CD の admin パスワードの操作いろいろ"
emoji: "🐙"
type: "tech"  # tech or idea
topics: ["argocd","password"]
published: true
---

# tl;dr

- Argo CD を運用するにあたって、パスワード変更について見ていた
- [公式で最初に出会う](https://argo-cd.readthedocs.io/en/stable/getting_started/#4-login-using-the-cli)
- [FAQ のパスワードを忘れた時](https://argo-cd.readthedocs.io/en/stable/faq/#i-forgot-the-admin-password-how-do-i-reset-it)
- zenn のスクラップを使って整理したので記事にした

# Argo CD の admin パスワード

## 初期パスワード

### プラグイン類を使わない（kubectlだけあればおｋ）

```bash
kubectl get secret/argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d; echo
```

### view-secret プラグインを使う（krew等で view-secret plugin を入れてあれば）

```bash
kubectl view-secret argocd-initial-admin-secret -n argocd ; echo
```

### argocd cli を使う（公式の初期パスワード取得方法。argocd cli を入れる必要がある）

```bash
argocd admin initial-password -n argocd
```

:::message alert
初期パスワードを変更して、secret を削除して、これらは使わないようにする必要がある。
:::

## パスワード変更

パスワードはログイン後に User Info の UPDATE PASSWORD で変更できる。
（画面から変更するとログアウトさせられて再ログインが必要になる）

### パスワードを変更する

```bash
argocd account update-password
```

### 初期パスワードの入った secret を削除する

```bash
kubectl --namespace argocd delete secret/argocd-initial-admin-secret
```

## パスワードを忘れてしまったら

変更したパスワードを忘れるとか言語道断なので深く反省すること。

手順は公式のとおり

@[card](https://argo-cd.readthedocs.io/en/stable/faq/#i-forgot-the-admin-password-how-do-i-reset-it)

### 方法１

- bcrypt でハッシュ化されたパスワードを生成する

```bash
export NEW_PASS=`argocd account bcrypt --password 123456789`
```

- パスワード 123456789 の結果。bcrypt なので同じ値にはならない

```bash
echo $NEW_PASS
$2a$10$/sxME6TKhWMzTbMo5wxh/OJmF2iQZumrB7I9Y5C47lGp1R22xQdXm
```

- 更新する（公式のやつ長いから１行に収めたかった。というかコピペしやすくしたかった）

```bash
kubectl -n argocd patch secret argocd-secret -p '{"stringData": {"admin.password": "'$(echo $NEW_PASS)'", "admin.passwordMtime": "'$(date +%FT%T%Z)'" }}'
```

### 方法２

もう一つの、ドキュメントには手順（コード）が書かれていない方の手順

- secret の値を消す

```bash
kubectl patch secret argocd-secret -n argocd -p '{"data": {"admin.password": null, "admin.passwordMtime": null}}'
```

- pod を削除する（deploymentで勝手に上がってくるから大丈夫）

```bash
kubectl delete pods -n argocd -l app.kubernetes.io/name=argocd-server
```

- 初期パスワードが再設定されているので最初に戻ってやり直し

# まとめ

- 管理者パスワードの CRUD は運用する上で避けては通れない（なのでこういうページは公式ドキュメントで整理して欲しいな）
- 再設定しても特に問題は起きない（安心して更新していい）
- 逆に運用を任されたら即パスワード変更を行って、影響範囲の確認を実施することをおすすめする（怒られても責任は取れないけど）
