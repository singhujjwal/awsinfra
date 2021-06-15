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
