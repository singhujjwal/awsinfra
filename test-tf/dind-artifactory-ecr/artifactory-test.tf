
locals {

  account_id    = data.aws_caller_identity.current.account_id
  region        = data.aws_region.current.name
  OIDC_PROVIDER = split("://", data.aws_eks_cluster.example.identity[0].oidc[0].issuer)
  oidc_arn      = "arn:aws:iam::${local.account_id}:oidc-provider/${local.OIDC_PROVIDER[1]}"


  ecr_config_file = ".ecr-config.yaml"

  ecr_descriptors = yamldecode(
    file(local.ecr_config_file)
  ).ecr_repositories

  ecr_descriptors_map = {
    for ecr_repo in local.ecr_descriptors :
    ecr_repo.account_id => ecr_repo.regions
  }

  ecr_details = flatten([
    for ecr_repo in local.ecr_descriptors : [
      for r in ecr_repo.regions : {
        account_id = ecr_repo.account_id
        region     = r.name
      }
    ]
  ])


  ecr_helper_map = {
    for item in local.ecr_details : 
      join("", [item.account_id, ".dkr.ecr.", item.region, ".amazonaws.com"]) => "ecr-login"
  }

}

output "ecr_descriptors_map" {
  value = local.ecr_descriptors_map
}


output "ecr_details" {
  value = local.ecr_details
}

output "ecr_helper_map" {
  value = local.ecr_helper_map
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_eks_cluster" "example" {
  name = "my-cluster"
}


data "tls_certificate" "example" {
  url = data.aws_eks_cluster.example.identity[0].oidc[0].issuer
}


resource "kubernetes_config_map" "docker_config" {
  metadata {
    name      = "ujjwal"
    namespace = "ujjwal-agent"
  }


  data = {
    "config.json" = jsonencode(
      {
        auths = {
          "https://singhujjwal.jfrog.io" = {
            "auth" = "c2luZ2h1amp3YWw6S2lud2FhckAxMjM="
          }
        },
        credHelpers = local.ecr_helper_map
      }
    )
  }
}

resource "aws_iam_role" "service_account_roles" {
  name = "pod_role_service_account"

  assume_role_policy = data.aws_iam_policy_document.web_identity_trusts.json
}

resource "kubernetes_service_account" "this" {

  metadata {
    name      = "service-account2"
    namespace = "ujjwal-agent"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.service_account_roles.arn
    }
  }
  automount_service_account_token = true
}

