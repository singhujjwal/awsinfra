output "instances" {
  // value       = aws_instance.master_jenkins.public_ip
  value       = aws_instance.master_jenkins.private_ip
  description = "PrivateIP address details"
  
}

output "region" {
  description = "AWS region."
  value       = var.region
}

output "TF_VAR_vpc_id" {
  description = "AWS VPC id"
  value       = local.vpc_id
}


output "TF_VAR_public_subnets" {
  description = "AWS Public Subnets"
  value       = local.public_subnets
}

output "TF_VAR_private_subnets" {
  description = "AWS Private Subnets"
  value       = local.private_subnets
}


output "public_ip" {
value = local.my_public_ip
}
