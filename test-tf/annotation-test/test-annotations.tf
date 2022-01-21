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


data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
 
  account_id           = data.aws_caller_identity.current.account_id
  region               = data.aws_region.current.name

}

resource "aws_ecr_repository" "foo" {
  name                 = "ujjwal-ecr-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}


resource "kubernetes_config_map" "docker_config" {
  metadata {
    name        = "ujjwal"
    namespace   = "ujjwal-agent"
  }

  data = {
    "config.json" = jsonencode(
      {
        auths = {
          "https://singhujjwal.jfrog.io" = {
            "auth" = "c2luZ2h1amp3YWw6S2lud2FhckAxMjMK"
          }
        },
        credHelpers = {
          "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com" = "ecr-login"
        }
      }
    )
  }
}


variable "common_tags" {
  type = map(string)
  default = {

    "Application" : "ceks-cluster",
    "BusinessUnit" : "test",
    "Origin" : "terraform",

  }

}
