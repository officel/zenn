resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.10.1" # see releases

  namespace        = "ingress-nginx"
  create_namespace = true

  values = [file("helm_ingress_nginx_values.yaml")]

  depends_on = [kind_cluster.this]
}
