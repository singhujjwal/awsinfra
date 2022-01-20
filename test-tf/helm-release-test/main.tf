terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.47.0"
      region  = "ap-south-1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 1.3.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 1.13.3"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
  }
  required_version = "~> 0.13.7"
}

provider "aws" {
  region = "ap-south-1"
}



resource "helm_release" "artifactory_ha" {
  name             = "artifactory"
  chart            = "artifactory"
  repository       = "https://charts.jfrog.io"
  version          = "107.27.10"
  cleanup_on_fail  = true
  create_namespace = true
  force_update     = true
  namespace        = "test"
  timeout          = 1000


  values = [yamlencode({
    postgresql = {
        enabled = false
    }
    nginx = {
      service = {
        annotations = {
          "service.beta.kubernetes.io/aws-load-balancer-internal" = "true"
        }
      }
    }
  })]

  provisioner "local-exec" {
    command = "echo ${self.values} >> myfile.json"
  }

}
