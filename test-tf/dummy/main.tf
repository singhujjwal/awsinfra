locals {
  x = "Ujjwal Singh"
  final_url = "${var.artifactory_fqdn}/${var.docker_repo_name}/${var.agent_image}"

  val1 = [yamlencode({
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

  val2 = [yamlencode({
    postgresql = {
      enabled = "false"
    }
    nginx = {
      service = {
        annotations = {
          "service.beta.kubernetes.io/aws-load-balancer-internal" = "true"
        }
      }
    }
  })]

  val3 = yamlencode({
    postgresql = {
      enabled = "false"
    }
    nginx = {
      service = {
        annotations = {
          "service.beta.kubernetes.io/aws-load-balancer-internal" = "true"
        }
      }
    }
  })

  val4 = yamlencode({
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
  })

  common_secret = jsondecode(data.aws_secretsmanager_secret_version.common_secret.secret_string)
  username = "username"
  password = "password"
  


  data = {
    "config.json" = jsonencode(
      {
        auths = {
          (var.artifactory_fqdn) = {
            "auth" = base64encode(
              "${local.common_secret[local.username]}:${local.common_secret[local.password]}"
            )
          }
        },
        credHelpers = "asdsadsadadsaasdad"
      }
    )
  }

  


}

output "image" {
  value = local.final_url
  
}


output "data" {

  value = local.data

}

variable "artifactory_fqdn" {
  type = string
  default = "artifactory.sophos-tools.com"
  
}
variable "docker_repo_name" {
  type = string
  default = "central-jenkins-agent"
  
}

variable "agent_image" {
  type = string
  default = "inbound-agent"
  
}


data "aws_secretsmanager_secret" "common_secret_name" {
  name = "ujjwal/secrets/common"
}

data "aws_secretsmanager_secret_version" "common_secret" {
  secret_id = data.aws_secretsmanager_secret.common_secret_name.arn
}



# output "mysecret" {

#   value  = lookup( local.common_secret, "is_source_base64_encoded", false
#     ) ? base64decode(
#     local.common_secret["password"]
#     ) : local.common_secret["password"]
# }


# lookup(
#       data_block,
#       "is_source_base64_encoded",
#       false
#       ) ? base64decode(
#       local.secret[data_block.source_key]
#     )


# resource "kubernetes_config_map" "name" {
#   count = var.jenkins_identifier == "ujjenkins" ? 1 :0 

#    metadata {
#     name        = "ujjwal-test-configmap"
#   }

#   data = {
#     "config.json" = jsonencode(
#       {
#         credHelpers = {
#           "name" = "ecr-login"
#         }
#       }
#     )
#   }

# }


variable "jenkins_identifier" {
  type    = string
  default = "ujjenkin"

}

output "yaml1" {
  value = local.val1[0]
}

output "yaml2" {
  value = local.val2[0]
}

output "yaml3" {
  value = local.val3
}

output "yaml4" {
  value = local.val4
}

output "my_x_value_output" {
  value = local.x
}

