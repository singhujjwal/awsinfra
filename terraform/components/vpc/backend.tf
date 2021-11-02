terraform {
  backend "s3" {
    bucket         = "ujjwal-tf-bucket"
    key            = "awsinfra/tfstate/components/vpc/vpc.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "tfstate-table"
  }
}
