locals {
  service_account_descriptors = {
    for k, v in {
      ("key1") = [
        "controller",
        "serviceAccount"
      ],
      ("key2") = [
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
}

output "name" {

    value = local.service_account_descriptors["key1"]
  
}