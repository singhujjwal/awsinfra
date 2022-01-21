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
}

data "aws_availability_zones" "available" {
}

data "aws_vpc" "this_vpc" {
  id = local.vpc_id
}

data "terraform_remote_state" "vpc" {
  count   = var.vpc_tfstate_bucket_key != "null" ? "1" : "0"
  backend = "s3"

  config = {
    bucket = var.vpc_tfstate_bucket_name
    key    = var.vpc_tfstate_bucket_key
    region = var.region
  }

  defaults = {
    vpc_id          = ""
    private_subnets = []
    public_subnets  = []
  }
}

data "aws_ssm_parameter" "private_ssh_key" {
  name = local.private_ssh_key_ssm_path
}


locals {
  vpc_id = var.vpc_id != "null" ? var.vpc_id : (var.vpc_tfstate_bucket_key == "null" ? "null" : data.terraform_remote_state.vpc[0].outputs.vpc_id)

  private_subnets = split(
    ",",
    length(var.private_subnets) != 0 ? join(",", var.private_subnets) : (var.vpc_tfstate_bucket_key == "null" ? "null" : join(",", data.terraform_remote_state.vpc[0].outputs.private_subnets)),
  )
  public_subnets = split(
    ",",
    length(var.public_subnets) != 0 ? join(",", var.public_subnets) : (var.vpc_tfstate_bucket_key == "null" ? "null" : join(",", data.terraform_remote_state.vpc[0].outputs.public_subnets)),
  )
  key_pair_name = var.key_pair_name
  private_ssh_key_ssm_path = var.private_ssh_key_ssm_path

  my_public_ip = "${trimspace(data.http.terraform_host_public_ip.body)}/32"
}



resource "aws_instance" "eks-bastion-instance" {
  ami           = ""
  count         = 1
  subnet_id     = local.public_subnets[0]
  instance_type = ""
  key_name = local.key_pair_name

  vpc_security_group_ids      = [aws_security_group.allow_ssh_access.id]
  associate_public_ip_address = false


  root_block_device {
    volume_type           = "gp2"
    volume_size           = "35"
    delete_on_termination = true
  }

}


module "test_instance" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"

  name                   = "my-tiny"
  instance_count         = 1

  ami                    = "ami-026f33d38b6410e30"
  instance_type          = "t2.micro"
  key_name               = local.key_pair_name
  monitoring             = false
  vpc_security_group_ids = [aws_security_group.allow_ssh_access.id]
  subnet_id              = local.public_subnets[0]
  associate_public_ip_address = false

}


resource "aws_eip" "lb" {
  instance = one(module.test_instance.id)
  vpc      = true
  depends_on = [module.test_instance]
}



#data "http" "terraform_host_private_ip" {
#  url = "http://169.254.169.254/latest/meta-data/local-ipv4"
#}

data "http" "terraform_host_public_ip" {
  url = "https://checkip.amazonaws.com"
}


resource "aws_security_group" "allow_ssh_access" {
  name        = "allow_ssh_access"
  description = "Allow all inbound traffic from local laptop"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # cidr_blocks = ["${trimspace(data.http.terraform_host_public_ip.body)}/32", "${trimspace(data.http.terraform_host_private_ip.body)}/32"]
    cidr_blocks = ["${trimspace(data.http.terraform_host_public_ip.body)}/32"]
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
}
