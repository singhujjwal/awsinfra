terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "aws" {
  region = var.region
}

data "aws_iam_account_alias" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

//Create a role with assume role policy of type ec2
resource "aws_iam_role" "jenkins_master" {
  name               = "${var.name}_jenkins"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
}


//Create an instance profile
resource "aws_iam_instance_profile" "jenkins_master" {
  name = "${var.name}_jenkins"
  role = aws_iam_role.jenkins_master.name
}

//Create another policy and attach to the role.
resource "aws_iam_role_policy" "jenkins" {
  name = "${var.name}_jenkins"
  role = aws_iam_role.jenkins_master.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:GetRepositoryPolicy",
            "ecr:DescribeRepositories",
            "ecr:ListImages",
            "ecr:BatchGetImage"
          ],
          "Resource": [
            "*"
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "s3:*"
          ],
          "Resource": [
            "${aws_s3_bucket.jenkins.arn}",
            "${aws_s3_bucket.jenkins.arn}/*"
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "kms:*"
          ],
          "Resource": [
            "${aws_kms_key.jenkins.arn}"
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "iam:ListAccountAliases",
            "route53:ListHostedZones",
            "route53:GetHostedZone",
            "route53:ListResourceRecordSets",
            "ec2:DescribeImages",
            "ec2:DescribeSecurityGroups",
            "autoscaling:DescribeAutoscalingGroups",
            "elasticloadbalancing:DescribeLoadBalancers",
            "elasticloadbalancing:DescribeLoadBalancerAttributes",
            "autoscaling:DescribeLaunchConfigurations"
          ],
          "Resource": [
            "*"
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "iam:GetRole",
            "iam:GetRolePolicy"
          ],
          "Resource": [
            "${aws_iam_role.jenkins_master.arn}"
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "iam:GetInstanceProfile"
          ],
          "Resource": [
            "${aws_iam_instance_profile.jenkins_master.arn}"
          ]
        }
    ]
}
EOF
}


resource "aws_iam_role_policy" "jenkins_ec2_plugin" {
  name = "${var.name}_ec2_plugin"
  role = aws_iam_role.jenkins_master.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1312295543082",
            "Action": [
                "ec2:DescribeSpotInstanceRequests",
                "ec2:CancelSpotInstanceRequests",
                "ec2:GetConsoleOutput",
                "ec2:RequestSpotInstances",
                "ec2:RunInstances",
                "ec2:StartInstances",
                "ec2:StopInstances",
                "ec2:TerminateInstances",
                "ec2:CreateTags",
                "ec2:DeleteTags",
                "ec2:DescribeInstances",
                "ec2:DescribeKeyPairs",
                "ec2:DescribeRegions",
                "ec2:DescribeImages",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "iam:ListInstanceProfilesForRole",
                "iam:PassRole"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
  EOF
}

#
# attach SSM policy to role to permit management from SSM
#
resource "aws_iam_role_policy_attachment" "attach_ssm_permissions" {
  role       = aws_iam_role.jenkins_master.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}


resource "aws_s3_bucket" "jenkins" {
  bucket = "ujjwal-${data.aws_iam_account_alias.current.account_alias}-${var.region}-jenkins"
  acl    = "private"

  versioning {
    enabled = true
  }
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "aws_kms_key" "jenkins" {
  description = "key used for encrypting jenkins config"
}

resource "aws_security_group" "jenkins_master" {
  name        = "${var.name}_jenkins_master"
  description = "Allow traffic for jenkin_master"

  vpc_id = var.vpc_id

  # keep CIDR block at 10.0.0.0/8 to avoid the cleanup lambda

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "internal communication"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}_jenkins_master_access"
  }
}

resource "aws_instance" "master_jenkins" {
  ami                         = var.master_instance_ami
  instance_type               = var.master_instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.jenkins_master.id]
  associate_public_ip_address = true
  source_dest_check           = false
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.jenkins_master.id

  user_data = <<EOF
#!/bin/bash
echo "Setting up Jenkins"
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum -y upgrade
sudo amazon-linux-extras install -y epel
sudo amazon-linux-extras install -y java-openjdk11
sudo yum install -y jenkins
sudo systemctl daemon-reload
sudo systemctl start jenkins
sudo systemctl status jenkins
echo "Check if jenkins is running"
sudo systemctl status jenkins
EOF
  tags = {
    Name = "${var.name}-Master"
  }
}

