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

data "template_file" "json_template" {
  template = file("docker-config.json")
  vars = {
    ACCOUNT_ID = var.account_id,
    REGION     = var.region

  }
}



resource "helm_release" "artifactory_ha" {
  name             = "artifactory"
  chart            = "artifactory"
  repository       = var.artifactory_helm_repo_url
  version          = var.artifactory_version
  cleanup_on_fail  = true
  create_namespace = true
  force_update     = true
  namespace        = local.artifactory_namespace
  timeout          = var.helm_release_timeout


  values = [yamlencode({
    artifactory = {
      service = {
        annotations = {
          \"service.beta.kubernetes.io/aws-load-balancer-internal\" = "true"
        }
      }
    }
  })]
}





# resource "kubernetes_config_map" "docker_config" {
#   metadata {
#     name        = "ujjwal"
#     namespace   = "agent"
#   }

#   data = {
#     "config.json" = data.template_file.json_template.rendered
#   }
# }

variable "account_id" {
  type    = string
  default = "458516813260"
}

variable "region" {
  type    = string
  default = "ap-south-1"
}


variable "installation_namespace" {
  type    = string
  default = "test"
}

variable "agent_namespace" {
  type    = string
  default = "agent"
}


variable "common_tags" {
  type = map(string)
  default = {

    "Application" : "ceks-cluster",
    "BusinessUnit" : "test",
    "Origin" : "terraform",

  }

}


locals {
  service_account_descriptors = {
    for k, v in {
      (var.installation_namespace) = [
        "controller",
        "serviceAccount"
      ],
      (var.agent_namespace) = [
        "agent",
        "serviceAccountAgent"
      ]
    } :
    k => {
      helm_value_name = v[1]
      iam_role_name   = "${k}-role"
      iam_role_path   = "/${v[0]}/"
      type            = v[0]
    }
  }

  service_accounts = {
    for k, v in local.service_account_descriptors :
    v.helm_value_name => {
      create = true
      name   = k
      annotations = merge(
        var.common_tags,
        {
          "eks.amazonaws.com/role-arn" = "xyz"
        }
      )
    }
  }
}



data "aws_iam_role" "ecr" {
  name = "ecsInstanceRole"
}


resource "aws_iam_role_policy" "artifacts_inline_policies" {
  name   = "artifacts-ecr-push-policy"
  role   = data.aws_iam_role.ecr.id
  policy = data.aws_iam_policy_document.ecr_push_access.json
}

data "aws_arn" "ecr_arn" {
  arn = "arn:aws:ecr:ap-south-1:458516813260:repository/ujjwal"
}

output "account_id_arn_way" {
    value = data.aws_arn.ecr_arn.account
}


# var.cluster_oidc_provider.arn

data "aws_iam_policy_document" "ecr_push_access" {

  statement {
    sid    = "AllowECRPush"
    effect = "Allow"

    resources = [
      "arn:aws:ecr:${var.region}:${data.aws_arn.ecr_arn.account}:repository/ujjwal"
    ]

    actions = [
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:GetDownloadUrlForLayer",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
    ]
  }
}


resource "aws_iam_role" "service_account_roles" {
  for_each = local.service_account_descriptors

  name = each.value.iam_role_name
  path = each.value.iam_role_path

  //assume_role_policy = data.aws_iam_policy_document.ecr_push_access.json
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name = each.value.iam_role_name
    }
  )
}


resource "aws_iam_role_policy" "artifacts_inline_policies_new" {

  name = "artifacts-s3-policy"
  role = aws_iam_role.service_account_roles["agent"].id

  policy = data.aws_iam_policy_document.ecr_push_access.json
}



data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
    account_id = data.aws_caller_identity.current.account_id
    region = data.aws_region.current.name
}

output "account_id" {
  value = local.account_id
}

output "current_region" {
    value = local.region

}