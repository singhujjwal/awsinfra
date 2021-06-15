output "region" {
  description = "AWS region."
  value       = var.region
}

output "TF_VAR_vpc_id" {
  description = "AWS VPC id"
  value       = local.vpc_id
}
