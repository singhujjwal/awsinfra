variable "vpc_name" {}

locals {
  vpc_name                      = var.vpc_name
  ami_type                      = "AL2_x86_64"
  worker_node_asg_instance_type = "t2.small"
}


data "aws_vpc" "vpc" {
  tags = {
    Name = local.vpc_name
  }
}

data "aws_subnet" "selected" {
  filter {
    name   = "tag:Name"
    values = ["Public-Subnet"]
  }
}

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_version = "1.21"
  cluster_name    = "my-cluster"
  vpc_id          = data.aws_vpc.vpc.id
  subnets         = [data.aws_subnet.selected]


  node_groups_defaults = {
    ami_type         = local.ami_type
    instance_types   = local.worker_node_asg_instance_type
    desired_capacity = 1
    max_capacity     = 10
    min_capacity     = 1
  }

  worker_groups = [
    {
      instance_type = "m4.large"
      asg_max_size  = 1
    }
  ]
}