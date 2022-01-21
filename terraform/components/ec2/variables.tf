variable "vpc_id" {}

variable "subnet_id" {}

variable "name" {

}

variable "region" {

}

variable "master_instance_type" {

}

variable "key_name" {

}

variable "master_instance_ami" {

}
variable "vpc_tfstate_bucket_name" {
}

variable "vpc_tfstate_bucket_key" {
}

variable "region" {
}

variable "vpc_id" {
}

variable "public_subnets" {
  type = list(string)
}


variable "private_subnets" {
  type = list(string)
}

variable "private_ssh_key_ssm_path" {
}

variable "key_pair_name" {
}

