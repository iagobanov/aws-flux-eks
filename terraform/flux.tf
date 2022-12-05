terraform {
  required_version = ">= 0.13"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.2"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.10.0"
    }
  }
}


provider "kubectl" {}

locals {
  envs = ["dev", "homol", "prod", "flux-system"]
}
resource "kubernetes_namespace" "envs" {
  for_each = toset(local.envs)
  metadata {
    name = each.key
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }
}

resource "null_resource" "flux_bootstrap" {
  provisioner "local-exec" {
    command = "flux bootstrap github --owner=${var.github_owner} --repository=${var.repository_name} --path=./cluster --read-write-key --branch=main --namespace=flux-system --components-extra=image-reflector-controller,image-automation-controller"
  }

  depends_on = [module.eks_blueprints]
}
