# awsinfra
For my personal infra creation and destructions 

# terraform
All modules code in terraform
Can be initilaized with terragrunt or can be directly run by terraform

# live
Live repo referring the above terraform code.
Can be directly used with terragrunt to track a live infrastructure repo

# aws-nuke
Nuke all resources in an AWS account if terraform fails for some reason.
the best case will be not to need aws-nuke but when it fails use it.

# eks

Terraform code to create EKS, although an eksctl is an easy way for doing poc

# test-tf

Terraform playground to test the terraform language on live environments

## k8s-poc
 [*] helm chart test
 [*] nginx test
 [*] external-dns test  

# Ignore changes in git
Helpful in not tracking the tfvars files
git update-index --assume-unchanged [file-path]
