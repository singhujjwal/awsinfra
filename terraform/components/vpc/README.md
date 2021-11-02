This is a pure terraform module and it should be able to deployed independently of anything e.g. terragrunt.

So for that reason don't keep the bucket name in the backend file rather use the command

## HAHA new terraform doesnt support terraform remote, you need terraform enterprise for that, else better use it with terragrunt to keep DRY code for backend configurations.

# It wont work at all -----------So use Terragrunt here 

`terraform remote config -backend=s3 -backend-config="bucket=ujjwal-tf-bucket" backend-config="key=awsinfra/tfstate/components/vpc/vpc.tfstate" -backend-config="region=ap-south-1"`
