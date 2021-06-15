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
