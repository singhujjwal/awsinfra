# Add locking mechanism later
terraform {
  backend "s3" {
    bucket         = "ujjwal-tf-bucket"
    key            = "awsinfra/tfstate/components/test/test.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "tfstate-table"
  }
  required_version = "~> 1.0.0"
}
