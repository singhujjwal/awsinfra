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
}



