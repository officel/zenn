---
title: "今更ながら kubectl のプラグインを krew で管理することにしまして"
emoji: "🔌"
type: "tech"  # tech or idea
topics: ["kubernetes","k8s","kubectl","krew","plugin"]
published: true
---

# tl;dr

- 職場の slack で kubectl のプラグインの共有会がしたいという声があがる
- 普段使わないので（そっち寄りじゃないので）管理が適当になっていた
- というわけで整理した

# やったこと

- [fix: remove kubectl plugins](https://github.com/officel/config_aqua/pull/50) aqua 管理から外した
- [fix: use kubecolor wraped kubectl](https://github.com/officel/config_bash/pull/16) alias 少しいじった
- 要は aqua で管理していた kubernetes 関係のツールのうち、krew に移行して良さそうなものを移行した
- aqua で krew を入れると `kubectl krew` が動かない（`~/.krew/bin`にリンクしないせい？）のが気になっていた（他のツールと同じで `krew` として実行していた）
- [config_bash/k8s.md](https://github.com/officel/config_bash/blob/07bedf0bb6c112bb7b6e68d11b5f78ddbbdf928c/k8s.md) のとおり
- インストールしたプラグインの管理方法がわかってなかったので aqua を使っていたんだけど、krew でリストの出力とそこからの復元方法がわかったので移行に踏み切ったってワケ

# インストールしているプラグイン

```bash
$ k krew list
access-matrix
assert
aws-auth
cond
config-cleanup
ctx
deprecations
graph
iexec
images
krew
ktop
kubescape
kuttl
neat
ns
open-svc
popeye
resource-capacity
retina
score
sniff
status
stern
tree
view-secret
view-utilization
who-can
whoami
```

- せっかくなので info の結果もつける（各プラグインのリンクも正確に出力されるしね）
- プラグイン毎の使い方とか学びを別途記事にする予定（宣言駆動）

```bash
k krew list | xargs -i sh -c 'echo "## {}\n\n\`\`\`bash\n\$ kubectl krew info {}" && kubectl krew info {} && echo "\`\`\`\n"'
```

:::details 邪魔だからたたむ

## access-matrix

```bash
$ kubectl krew info access-matrix
NAME: access-matrix
INDEX: default
URI: https://github.com/corneliusweig/rakkess/releases/download/v0.5.0/access-matrix-amd64-linux.tar.gz
SHA256: 3217c192703d1d62ef7c51a3d50979eaa8f3c73c9a2d5d0727d4fbe07d89857a
VERSION: v0.5.0
HOMEPAGE: https://github.com/corneliusweig/rakkess
DESCRIPTION:
Show an access matrix for server resources

This plugin retrieves the full list of server resources, checks access for
the current user with the given verbs, and prints the result as a matrix.
This complements the usual "kubectl auth can-i" command, which works for
a single resource and a single verb. For example:
 $ kubectl access-matrix

It also supports a mode which prints all subjects with access to a given
resource (needs read access to Roles and ClusterRoles). For example:
 $ kubectl access-matrix for configmap

CAVEATS:
\
 | Usage:
 |   kubectl access-matrix
 |   kubectl access-matrix for pods
/
```

## assert

```bash
$ kubectl krew info assert
NAME: assert
INDEX: default
URI: https://github.com/morningspace/kubeassert/archive/v0.2.0.tar.gz
SHA256: a35b62a111212a74c954f2991fdfa7b4cad8e92b9318773f87c9ff8c12a5ea52
VERSION: v0.2.0
HOMEPAGE: https://github.com/morningspace/kubeassert
DESCRIPTION:
Provides a set of assertions that can be used to quickly
assert Kubernetes resources from the command line against
your working cluster.

```

## aws-auth

```bash
$ kubectl krew info aws-auth
NAME: aws-auth
INDEX: default
URI: https://github.com/keikoproj/aws-auth/releases/download/v0.5.0/aws-auth_v0.5.0_linux_amd64.tar.gz
SHA256: 4969e9c80ef5adc1fa48a841e7a308e382ac84a48718ace24249d5b5f12fb686
VERSION: v0.5.0
HOMEPAGE: https://github.com/keikoproj/aws-auth
DESCRIPTION:
This plugin allows upserting and removing IAM mappings from the
aws-auth configmap in order to manage access to EKS clusters for
roles or users.

```

## cond

```bash
$ kubectl krew info cond
NAME: cond
INDEX: default
URI: https://github.com/ahmetb/kubectl-cond/releases/download/v0.2.0/kubectl-cond_v0.2.0_linux_amd64.tar.gz
SHA256: 3b0f0300c6c074eb7c07cd878f0a0a7f2b9b17f6d6f50918e74292386761e16f
VERSION: v0.2.0
HOMEPAGE: https://github.com/ahmetb/kubectl-cond
DESCRIPTION:
A human-friendly alternative to "kubectl describe" to view
resource conditions for Kubernetes objects.

```

## config-cleanup

```bash
$ kubectl krew info config-cleanup
NAME: config-cleanup
INDEX: default
URI: https://github.com/B23admin/kubectl-config-cleanup/releases/download/v0.6.0/kubectl-config-cleanup_0.6.0_linux_amd64.tar.gz
SHA256: 17dd97598f25b3fe1b1b5582dcf55016a5a870007dcc99e78f7cad65993375f6
VERSION: v0.6.0
HOMEPAGE: https://github.com/B23admin/kubectl-config-cleanup
DESCRIPTION:
This plugin will attempt to connect to each apiserver specified by a context entry in your kubeconfig.
If the connection succeeds then the user, cluster, and context entries are maintained in the result.
Otherwise, the entries are removed.

```

## ctx

```bash
$ kubectl krew info ctx
NAME: ctx
INDEX: default
URI: https://github.com/ahmetb/kubectx/archive/v0.9.5.tar.gz
SHA256: c94392fba8dfc5c8075161246749ef71c18f45da82759084664eb96027970004
VERSION: v0.9.5
HOMEPAGE: https://github.com/ahmetb/kubectx
DESCRIPTION:
Also known as "kubectx", a utility to switch between context entries in
your kubeconfig file efficiently.

CAVEATS:
\
 | If fzf is installed on your machine, you can interactively choose
 | between the entries using the arrow keys, or by fuzzy searching
 | as you type.
 | See https://github.com/ahmetb/kubectx for customization and details.
/
```

## deprecations

```bash
$ kubectl krew info deprecations
NAME: deprecations
INDEX: default
URI: https://github.com/rikatz/kubepug/releases/download/v1.6.1/kubepug_linux_amd64.tar.gz
SHA256: 77d2e24cada49d29c38bdd9b42780f5e308ff02b8349e458a4c1f152dc886a77
VERSION: v1.6.1
HOMEPAGE: https://github.com/rikatz/kubepug
DESCRIPTION:
This plugin shows all the deprecated objects in a Kubernetes cluster allowing
the operator to verify them before upgrading the cluster. It uses the
swagger.json version available in master branch of Kubernetes repository
(github.com/kubernetes/kubernetes) as a reference. The branch can be changed
to some other desired Kubernetes version

CAVEATS:
\
 | * By default, deprecations finds deprecated object relative to the current kubernetes
 | master branch. To target a different kubernetes release, use the --k8s-version
 | argument.
 |
 | * Deprecations needs permission to GET all objects in the Cluster
/
```

## graph

```bash
$ kubectl krew info graph
NAME: graph
INDEX: default
URI: https://github.com/steveteuber/kubectl-graph/releases/download/v0.7.0/kubectl-graph_v0.7.0_linux_amd64.tar.gz
SHA256: c38acabd9f1ab841118fee788a5bc73a1dd9683b7addf76117f85eafa1accd24
VERSION: v0.7.0
HOMEPAGE: https://github.com/steveteuber/kubectl-graph
DESCRIPTION:
This plugin generates a visual representation of Kubernetes resources and
relationships. The graph is outputted in AQL, CQL or DOT format which can
be used by ArangoDB, Neo4j or Graphviz.

CAVEATS:
\
 | This plugin requires Graphviz or Neo4j to visualize the dependency graph.
 | Please see the quickstart guide for more information:
 | https://github.com/steveteuber/kubectl-graph#quickstart
/
```

## iexec

```bash
$ kubectl krew info iexec
NAME: iexec
INDEX: default
URI: https://github.com/gabeduke/kubectl-iexec/releases/download/v1.19.14/kubectl-iexec_v1.19.14_Linux_x86_64.tar.gz
SHA256: f0f381a9214f67b5e298920bb0376ddb9e52b90d604030a6e2fae2d075a8af39
VERSION: v1.19.14
HOMEPAGE: https://github.com/gabeduke/kubectl-iexec
DESCRIPTION:
Interactive pod and container selector for `kubectl exec`

CAVEATS:
\
 | To get help run: kubectl iexec --help
 | Examples:
 | Run command in container:
 |   kubectl iexec [pod] [command]
/
```

## images

```bash
$ kubectl krew info images
NAME: images
INDEX: default
URI: https://github.com/chenjiandongx/kubectl-images/releases/download/v0.6.3/kubectl-images_linux_amd64.tar.gz
SHA256: c50e2836c8f72e95d4b5d21990dd43d99dfeeaf21ae0d5438f9a828a639d4bcf
VERSION: v0.6.3
HOMEPAGE: https://github.com/chenjiandongx/kubectl-images
DESCRIPTION:
This plugin shows container images used in the Kubernetes cluster in a
table view. You can show all images or show images used in a specified
namespace.

```

## krew

```bash
$ kubectl krew info krew
NAME: krew
INDEX: default
URI: https://github.com/kubernetes-sigs/krew/releases/download/v0.4.4/krew-linux_amd64.tar.gz
SHA256: e471396b0ed4f2be092b4854cc030dfcbb12b86197972e7bef0cb89ad9c72477
VERSION: v0.4.4
HOMEPAGE: https://krew.sigs.k8s.io/
CAVEATS:
\
 | krew is now installed! To start using kubectl plugins, you need to add
 | krew's installation directory to your PATH:
 |
 |   * macOS/Linux:
 |     - Add the following to your ~/.bashrc or ~/.zshrc:
 |         export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
 |     - Restart your shell.
 |
 |   * Windows: Add %USERPROFILE%\.krew\bin to your PATH environment variable
 |
 | To list krew commands and to get help, run:
 |   $ kubectl krew
 | For a full list of available plugins, run:
 |   $ kubectl krew search
 |
 | You can find documentation at
 |   https://krew.sigs.k8s.io/docs/user-guide/quickstart/.
/
```

## ktop

```bash
$ kubectl krew info ktop
NAME: ktop
INDEX: default
URI: https://github.com/vladimirvivien/ktop/releases/download/v0.3.7/kubectl-ktop_v0.3.7_linux_amd64.tar.gz
SHA256: 6188b9d6d82d4434c184ec37a2021c1b90f467ba3e9d1a0f9fb21fa41823e76c
VERSION: v0.3.7
HOMEPAGE: https://github.com/vladimirvivien/ktop
DESCRIPTION:
This is a kubectl plugin for ktop, a top-like tool for displaying workload
metrics for a running Kubernetes cluster.
CAVEATS:
\
 | * By default, ktop displays metrics for resources in the default namespace. You can override this behavior
 | by providing a --namespace or use -A for all namespaces.
/
```

## kubescape

```bash
$ kubectl krew info kubescape
NAME: kubescape
INDEX: default
URI: https://github.com/kubescape/kubescape/releases/download/v3.0.3/kubescape-ubuntu-latest.tar.gz
SHA256: 91a6aa06b259b4d645f6be1e00709462be59f45226643e22bce77e73ded9eff5
VERSION: v3.0.3
HOMEPAGE: https://github.com/kubescape/kubescape/
DESCRIPTION:
It includes risk analysis, security compliance, and misconfiguration scanning
with an easy-to-use CLI interface, flexible output formats, and automated scanning capabilities.

```

## kuttl

```bash
$ kubectl krew info kuttl
NAME: kuttl
INDEX: default
URI: https://github.com/kudobuilder/kuttl/releases/download/v0.19.0/kuttl_0.19.0_linux_x86_64.tar.gz
SHA256: 9dfc7ec67bdf3f7fca0d38ef317fbcaa0996d6170a86bfe4b549b0c44ac7a7b7
VERSION: v0.19.0
HOMEPAGE: https://kuttl.dev/
DESCRIPTION:
The KUbernetes Test TooL (KUTTL) is a highly productive test
toolkit for testing operators on Kubernetes.

```

## neat

```bash
$ kubectl krew info neat
NAME: neat
INDEX: default
URI: https://github.com/itaysk/kubectl-neat/releases/download/v2.0.4/kubectl-neat_linux_amd64.tar.gz
SHA256: 2a4e0ce4988554e39e66135f3e6894434e7c8629fb173f40bc4e160dbc7f3f25
VERSION: v2.0.4
HOMEPAGE: https://github.com/itaysk/kubectl-neat
DESCRIPTION:
If you try to `kubectl get` resources you have just created,
they be unreadably verbose. `kubectl-neat` cleans that up by
removing default values, runtime information, and other internal fields.
Examples:
`$ kubectl get pod mypod -o yaml | kubectl neat`
`$ kubectl neat get -- pod mypod -o yaml`

```

## ns

```bash
$ kubectl krew info ns
NAME: ns
INDEX: default
URI: https://github.com/ahmetb/kubectx/archive/v0.9.5.tar.gz
SHA256: c94392fba8dfc5c8075161246749ef71c18f45da82759084664eb96027970004
VERSION: v0.9.5
HOMEPAGE: https://github.com/ahmetb/kubectx
DESCRIPTION:
Also known as "kubens", a utility to set your current namespace and switch
between them.

CAVEATS:
\
 | If fzf is installed on your machine, you can interactively choose
 | between the entries using the arrow keys, or by fuzzy searching
 | as you type.
/
```

## open-svc

```bash
$ kubectl krew info open-svc
NAME: open-svc
INDEX: default
URI: https://github.com/superbrothers/kubectl-open-svc-plugin/releases/download/v2.6.2/kubectl-open_svc-linux-amd64.zip
SHA256: cce5639b4acbab8af60a66ed377ba5d8a46964910cd7788c3b4fa64539bdda1a
VERSION: v2.6.2
HOMEPAGE: https://github.com/superbrothers/kubectl-open-svc-plugin
DESCRIPTION:
Open the Kubernetes URL(s) for the specified service in your browser.
Unlike the `kubectl port-forward` command, this plugin makes services
accessible via their ClusterIP.

```

## popeye

```bash
$ kubectl krew info popeye
NAME: popeye
INDEX: default
URI: https://github.com/derailed/popeye/releases/download/v0.11.1/popeye_Linux_x86_64.tar.gz
SHA256: d4471c3f5a3636ce9effc7e5c5d1ebeab44f11e828e4677e31a925cab90b66ae
VERSION: v0.11.1
HOMEPAGE: https://popeyecli.io
DESCRIPTION:
Popeye is a utility that scans live Kubernetes clusters and reports
potential issues with deployed resources and configurations.
It sanitizes your cluster based on what's deployed and not what's
sitting on disk. By scanning your cluster, it detects misconfigurations
and ensure best practices are in place thus preventing potential future
headaches. It aims at reducing the cognitive overload one faces when
operating a Kubernetes cluster in the wild. Furthermore, if your
cluster employs a metric-server, it reports potential resources
over/under allocations and attempts to warn you should your cluster
run out of capacity.

Popeye is a readonly tool, it does not alter any of your Kubernetes
resources in any way!

```

## resource-capacity

```bash
$ kubectl krew info resource-capacity
NAME: resource-capacity
INDEX: default
URI: https://github.com/robscott/kube-capacity/releases/download/v0.8.0/kube-capacity_v0.8.0_linux_x86_64.tar.gz
SHA256: 610ce6e5d7f528df1c60d3b5e277d00ac43cdfd9ce4d36f0b3132bb68fc12cf3
VERSION: v0.8.0
HOMEPAGE: https://github.com/robscott/kube-capacity
DESCRIPTION:
A simple CLI that provides an overview of the resource requests, limits, and utilization in a Kubernetes cluster.

```

## retina

```bash
$ kubectl krew info retina
NAME: retina
INDEX: default
URI: https://github.com/microsoft/retina/releases/download/v0.0.16/kubectl-retina-linux-amd64-v0.0.16.tar.gz
SHA256: a37510e9d9acc807feb8aecba0af0c5e4df291252819dd5fe8fa12624400a1a0
VERSION: v0.0.16
HOMEPAGE: https://github.com/microsoft/retina
DESCRIPTION:
The Retina CLI plugin enables users to collect distributed network captures in an
OS and vendor-agnostic way. Capture jobs can be created via the CLI to target specific
nodes or pods in a time-limited or size limited way. Capture jobs can also filter specific
network traffic based on the given configurations; more info on the configurations can be
found on the official docs. The captures are collected in formats like pcap, etl and
text files, and can then be stored at remote storage destinations.

```

## score

```bash
$ kubectl krew info score
NAME: score
INDEX: default
URI: https://github.com/zegl/kube-score/releases/download/v1.19.0/kube-score_1.19.0_linux_amd64.tar.gz
SHA256: a5b10e509bd845f0bc32a529f4e8165c021877f924ee6f6be66678039f75a761
VERSION: v1.19.0
HOMEPAGE: https://github.com/zegl/kube-score
DESCRIPTION:
Kubernetes object analysis with recommendations for improved reliability and security.
```

## sniff

```bash
$ kubectl krew info sniff
NAME: sniff
INDEX: default
URI: https://github.com/eldadru/ksniff/releases/download/v1.6.2/ksniff.zip
SHA256: c59b5c9ea84d6cb771096f1246c919b71389f9d4234e858f4929208957e561fd
VERSION: v1.6.2
HOMEPAGE: https://github.com/eldadru/ksniff
DESCRIPTION:
When working with micro-services, many times it's very helpful to get a capture of the network
activity between your micro-service and it's dependencies.

ksniff use kubectl to upload a statically compiled tcpdump binary to your pod and redirecting it's
output to your local Wireshark for smooth network debugging experience.

CAVEATS:
\
 | This plugin needs the following programs:
 | * wireshark (optional, used for live capture)
/
```

## status

```bash
$ kubectl krew info status
NAME: status
INDEX: default
URI: https://github.com/bergerx/kubectl-status/releases/download/v0.7.13/status_linux_amd64.tar.gz
SHA256: 814594703b110e6f463fd9491548cf102ae1f5daf9ca4cf2e3ce773dc687e33e
VERSION: v0.7.13
HOMEPAGE: https://github.com/bergerx/kubectl-status
DESCRIPTION:
Show status details of a given resource. Most useful when debugging Pod issues.

CAVEATS:
\
 | Usage:
 |   $ kubectl status
 |
 | For additional options:
 |   $ kubectl status --help
 |   or https://github.com/bergerx/kubectl-status/blob/master/doc/USAGE.md
/
```

## stern

```bash
$ kubectl krew info stern
NAME: stern
INDEX: default
URI: https://github.com/stern/stern/releases/download/v1.31.0/stern_1.31.0_linux_amd64.tar.gz
SHA256: c156c50f3ca2ae12c43f56198cbadce3c6334c020eccb265562a3ce57a73b7e3
VERSION: v1.31.0
HOMEPAGE: https://github.com/stern/stern
DESCRIPTION:
Stern allows you to `tail` multiple pods on Kubernetes and multiple containers
within the pod. Each result is color coded for quicker debugging.

The query is a regular expression so the pod name can easily be filtered and
you don't need to specify the exact id (for instance omitting the deployment
id). If a pod is deleted it gets removed from tail and if a new pod is added it
automatically gets tailed.

When a pod contains multiple containers Stern can tail all of them too without
having to do this manually for each one. Simply specify the `container` flag to
limit what containers to show. By default all containers are listened to.

```

## tree

```bash
$ kubectl krew info tree
NAME: tree
INDEX: default
URI: https://github.com/ahmetb/kubectl-tree/releases/download/v0.4.3/kubectl-tree_v0.4.3_linux_amd64.tar.gz
SHA256: 3f92e0025297c687fe219679a69bfdc126c7b706be6eb96b90a24d9905471b2d
VERSION: v0.4.3
HOMEPAGE: https://github.com/ahmetb/kubectl-tree
DESCRIPTION:
This plugin shows sub-resources of a specified Kubernetes API object in a
tree view in the command-line. The parent-child relationship is discovered
using ownerReferences on the child object.

CAVEATS:
\
 | * For resources that are not in default namespace, currently you must
 |   specify -n/--namespace explicitly (the current namespace setting is not
 |   yet used).
/
```

## view-secret

```bash
$ kubectl krew info view-secret
NAME: view-secret
INDEX: default
URI: https://github.com/elsesiy/kubectl-view-secret/releases/download/v0.13.0/kubectl-view-secret_v0.13.0_linux_amd64.tar.gz
SHA256: 859421994b10b0cd2eb8e91cc634dc8db0cdb1fd01e02cd7e4c3700ac47331cf
VERSION: v0.13.0
HOMEPAGE: https://github.com/elsesiy/kubectl-view-secret
DESCRIPTION:
Base64 decode by key or all key/value pairs in a given secret.

# print secret keys
$ kubectl view-secret <secret>

# decode specific entry
$ kubectl view-secret <secret> <key>

# decode all secret contents
$ kubectl view-secret <secret> -a/--all

# print keys for secret in different namespace
$ kubectl view-secret <secret> -n/--namespace foo

# print keys for secret in different context
$ kubectl view-secret <secret> -c/--context ctx

# print keys for secret by providing kubeconfig
$ kubectl view-secret <secret> -k/--kubeconfig <cfg>

# suppress info output
$ kubectl view-secret <secret> -q/--quiet

```

## view-utilization

```bash
$ kubectl krew info view-utilization
NAME: view-utilization
INDEX: default
URI: https://github.com/etopeter/kubectl-view-utilization/releases/download/v0.3.3/kubectl-view-utilization-v0.3.3.tar.gz
SHA256: bcdd9925d13ff3837f61336269f9d45e338ca14df2f8174120bd571217d99918
VERSION: v0.3.3
HOMEPAGE: https://github.com/etopeter/kubectl-view-utilization
DESCRIPTION:
This plugin shows cluster resource utilization based on cpu and memory. It collects pod requests and node available resources to calculate metrics.

CAVEATS:
\
 | This plugin needs the following programs:
 | * bash
 | * awk (gawk,mawk,awk)
/
```

## who-can

```bash
$ kubectl krew info who-can
NAME: who-can
INDEX: default
URI: https://github.com/aquasecurity/kubectl-who-can/releases/download/v0.4.0/kubectl-who-can_linux_x86_64.tar.gz
SHA256: 3ba4a529e2f759b13030e5fc803639fda6e13fd05ed0d8bda1c722459a298f32
VERSION: v0.4.0
HOMEPAGE: https://github.com/aquasecurity/kubectl-who-can
DESCRIPTION:
Shows which subjects have RBAC permissions to VERB [TYPE | TYPE/NAME | NONRESOURCEURL]

VERB is a logical Kubernetes API verb like 'get', 'list', 'watch', 'delete', etc.
TYPE is a Kubernetes resource. Shortcuts and API groups will be resolved, e.g. 'po' or 'pod.metrics.k8s.io'.
NAME is the name of a particular Kubernetes resource.
NONRESOURCEURL is a partial URL that starts with "/".

For example, if you want to find all subjects who have permission to
delete pods in a particular namespace, or to delete nodes in the cluster
(dangerous!) you could run the following commands:

$ kubectl who-can delete pods --namespace foo
$ kubectl who-can delete nodes

For usage or examples, run:

$ kubectl who-can -h

CAVEATS:
\
 | The plugin requires the rights to list (Cluster)Role and (Cluster)RoleBindings.
/
```

## whoami

```bash
$ kubectl krew info whoami
NAME: whoami
INDEX: default
URI: https://github.com/rajatjindal/kubectl-whoami/releases/download/v0.0.46/kubectl-whoami_v0.0.46_linux_amd64.tar.gz
SHA256: 37fe60a8b799896714d72442dd3df154fc4f286aec225206f423ec71295b25cc
VERSION: v0.0.46
HOMEPAGE: https://github.com/rajatjindal/kubectl-whoami
DESCRIPTION:
This plugin show the subject that's currently authenticated as.

```

:::

# 学びの途中

- [kubecolor/kubecolor](https://github.com/kubecolor/kubecolor) で出力を見やすくした
- [kubectl-plugins · GitHub Topics](https://github.com/topics/kubectl-plugins) でスター順に探したり
- [Kubectl plugins available · Krew](https://krew.sigs.k8s.io/plugins/) で公式（？）を探したり
- [ishantanu/awesome-kubectl-plugins](https://github.com/ishantanu/awesome-kubectl-plugins?tab=readme-ov-file) ですげぇのを探したりした
- 気になったりした
- @[tweet](https://x.com/raki/status/1845526047993029092)

# その他

- stern をプラグインで入れたら `stern` で呼べなくなるのを alias で握るか
- たぶん ktop とかも同じ

# まとめ

- `k krew list` でプラグイン共有会も大丈夫ｗ
- CKAD 失効してずいぶん経つし、勉強しなおさないといかん
- @[tweet](https://x.com/raki/status/1103063090986344450)
- @[tweet](https://x.com/raki/status/1367490581178507266)
