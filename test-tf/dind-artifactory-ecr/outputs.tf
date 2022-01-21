output "repo_url" {
  value = aws_ecr_repository.foo.repository_url
}

output "oidc_details" {
  value = data.aws_eks_cluster.example.identity[0].oidc[0].issuer
}

output "oidc_arn" {
  value = local.oidc_arn
}
