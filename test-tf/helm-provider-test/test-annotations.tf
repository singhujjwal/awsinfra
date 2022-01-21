terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.47.0"
      region  = "us-east-1"
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
  region = "us-east-1"
}


variable "common_tags" {
  type = map(string)
  default = {

    "Application" : "ceks-cluster",
    "BusinessUnit" : "test",
    "Origin" : "terraform",

  }
}

resource "helm_release" "example" {
  name       = "bitnami"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "jenkins"
  version    = "8.0.22"

  set {
    name  = "jenkinsUser"
    value = "ujjwalsingh"
  }

  set_sensitive {
    name  = "jenkinsPassword"
    value = "SuperStr0ng"
    type  = "string"
  }
}
