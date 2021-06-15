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

  ami                    = "ami-ebd02392"
  instance_type          = "t2.micro"
  key_name               = local.key_pair_name
  monitoring             = false
  vpc_security_group_ids = [aws_security_group.allow_ssh_access.id]
  subnet_id              = local.public_subnets[0]
  associate_public_ip_address = false


}


resource "aws_eip" "lb" {
  instance = module.test_instance.test_instance.id
  vpc      = true
}



data "http" "terraform_host_private_ip" {
  url = "http://169.254.169.254/latest/meta-data/local-ipv4"
}

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
    cidr_blocks = ["${trimspace(data.http.terraform_host_public_ip.body)}/32", "${trimspace(data.http.terraform_host_private_ip.body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
