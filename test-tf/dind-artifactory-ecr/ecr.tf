data "aws_iam_policy_document" "ecr_push_access" {

  statement {
    sid    = "AllowECRPush"
    effect = "Allow"

    resources = [
      "arn:aws:ecr:${local.region}:${local.account_id}:repository/*"
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

  statement {
    sid    = "GetAuthorizationToken"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "ecr_push_inline_policy" {
  name   = "ecr-container-push-policy"
  role   = aws_iam_role.service_account_roles.id
  policy = data.aws_iam_policy_document.ecr_push_access.json
}

resource "aws_ecr_repository" "foo" {
  name                 = "ujjwal-ecr-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}