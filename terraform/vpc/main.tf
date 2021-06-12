
data "aws_availability_zones" "available" {
}


locals {
  name   = var.vpc_name
  region = var.region
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_security_group" "vpc_base_sg" {
  name        = "vpc_endpoint_sg"
  description = "Allow all traffic between private subnets"
  vpc_id      = module.vpc.vpc_id
}

module "vpc_endpoints" {
  source             = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  vpc_id             = module.vpc.vpc_id
  security_group_ids = [data.aws_security_group.vpc_base_sg.id]

  endpoints = {
    s3 = {
      service = "s3"
      tags    = { Name = "s3-vpc-endpoint" }
    }
    //,
    // dynamodb = {
    //   # gateway endpoint
    //   service         = "dynamodb"
    //   route_table_ids = ["rt-12322456", "rt-43433343", "rt-11223344"]
    //   tags            = { Name = "dynamodb-vpc-endpoint" }
    // }
  }

  tags = merge(local.tags, {
    Project  = "Secret"
    Endpoint = "true"
  })

}


module "vpc" {
  source          = "terraform-aws-modules/vpc/aws"
  version         = "2.70.0"
  name            = var.vpc_name
  cidr            = var.vpc_cidr
  azs             = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1], data.aws_availability_zones.available.names[2]]
  private_subnets = var.vpc_private_subnet_list
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
  public_subnets = var.vpc_public_subnet_list
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  create_igw              = true
  enable_nat_gateway      = false
  single_nat_gateway      = true
  map_public_ip_on_launch = false

  enable_dhcp_options      = true
  enable_dns_hostnames     = true
  enable_dns_support       = true
  dhcp_options_domain_name = var.vpc_internal_domain_name

  dhcp_options_domain_name_servers = var.dns_server_list


  enable_s3_endpoint              = true
  ec2_endpoint_security_group_ids = [aws_security_group.vpc_base_sg.id]

  # Enable ec2 endpoint for instances in private subnet to access
  # aws resources via this endpoint rather than using the NAT gateway
  enable_ec2_endpoint = true

  secondary_cidr_blocks              = var.secondary_cidr_blocks
  create_redshift_subnet_group       = false
  create_elasticache_subnet_group    = false
  create_database_subnet_group       = false
  create_redshift_subnet_route_table = false
  create_database_subnet_route_table = false
}

