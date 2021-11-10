data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ujjwal_role1" {
  name               = "${var.name}_ujjwal_role1"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
}

## ABove creates just a role with no instance profile to create instance profile
## create below


resource "aws_iam_instance_profile" "ujjwal_instance_profile" {
  name = "${var.name}_instance_profile1"
  role = aws_iam_role.ujjwal_role1.name
}

## Attach policies, policies can be inline or separate, for inline policy 
# if something is added OOB it will be removed in next apply
## if something is removed OOB it will be applied in next apply

resource "aws_iam_role_policy" "manual_s3_read_only" {

name = "${var.name}_s3_read_only"
role = aws_iam_role.ujjwal_role1.id


policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*",
                "s3-object-lambda:Get*",
                "s3-object-lambda:List*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

## attach existing AWS managed policies to your role
data "aws_iam_policy" "S3ReadOnlyAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "s3-readonly-role-policy-attach" {
  role       = aws_iam_role.ujjwal_role1.name
  policy_arn = data.aws_iam_policy.S3ReadOnlyAccess.arn
}

data "aws_iam_policy" "SSMRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "ssm-role-policy-attach" {
  role       = aws_iam_role.ujjwal_role1.name
  policy_arn = data.aws_iam_policy.SSMRole.arn
}

//To attach multiple policy arns to a role this is the best way even you 
// can have a variable of list of managed arns 
/*
resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess", 
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ])

  role       = var.iam_role_name
  policy_arn = each.value
}
*/

