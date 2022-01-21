
data "aws_iam_policy_document" "web_identity_trusts" {

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_arn]
    }
  }
}


# resource "aws_iam_openid_connect_provider" "example" {
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = [data.tls_certificate.example.certificates[0].sha1_fingerprint]
#   url             = data.aws_eks_cluster.example.identity[0].oidc[0].issuer
# }