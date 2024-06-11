terraform {
  required_providers {
    kind = {
      source = "tehcyx/kind"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    helm = {
      source = "hashicorp/helm"
    }
  }
}

provider "kind" {}

provider "kubernetes" {
  config_path = pathexpand(local.kind_cluster_config_path)
}

provider "helm" {
  kubernetes {
    config_path = pathexpand(local.kind_cluster_config_path)
  }
}
