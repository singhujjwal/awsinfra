variable "region" {
}

variable "aws_access_key" {
}

variable "aws_secret_key" {
}

variable "aws_profile" {
}

variable "aws_assume_role" {
}


############################
### Start VPC Variables
############################

variable "vpc_name" {
  description = "Name of the VPC"
}

variable "vpc_cidr" {
  description = "Primary CIDR of the VPC"
}

variable "vpc_private_subnet_list" {
  type = list(string)
}

variable "vpc_public_subnet_list" {
  type = list(string)
}

variable "dns_server_list" {
  type        = list(string)
  description = "List of DNS server used by VPC"
}

variable "vpc_internal_domain_name" {
  description = "Domain name to be used inside VPC"
}

variable "secondary_cidr_blocks" {
  description = "The secondary CIDR block to be used in case of peering for gitlab"
  type        = list(string)
}

variable "tags" {
  description = "Tags to be applied to VPC"
  type        = map(string)
}

variable "enable_hosted_zone_association" {
  description = "Boolean to indicate whether to associate hosted zone with VPC automatically, in case of true provide the hosted zone id"
}

variable "hosted_zone_id" {
  description = "Hosted zone id to be associated with VPC"
}

