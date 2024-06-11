resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.1.2"

  namespace        = "argocd"
  create_namespace = true

  values = [file("helm_argocd_values.yaml")]

  depends_on = [
    kind_cluster.this,
    helm_release.ingress_nginx
  ]
}

resource "kubernetes_manifest" "ingress_argocd" {
  manifest = provider::kubernetes::manifest_decode(
    templatefile(
      "${path.module}/ingress_argocd.tftpl",
      { domain_argocd = var.domain_argocd }
    )
  )
  count = var.ingress_argocd ? 1 : 0

  depends_on = [
    kind_cluster.this,
    helm_release.argocd
  ]
}

variable "ingress_argocd" {
  type    = bool
  default = false
}

variable "domain_argocd" {
  type    = string
  default = "argocd.local"
}
