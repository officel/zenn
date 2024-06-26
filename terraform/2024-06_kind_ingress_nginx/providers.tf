terraform {
  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "~> 0.4.0"
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
