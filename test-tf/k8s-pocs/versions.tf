terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.47.0"
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
  required_version = "~> 1.0"
}

provider "aws" {
  region = "ap-south-1"
}


variable "common_tags" {
  type = map(string)
  default = {

    "Application" : "ceks-cluster",
    "BusinessUnit" : "test",
    "Origin" : "terraform",

  }
}
