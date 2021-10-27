# Add locking mechanism later
terraform {
  backend "s3" {
    bucket         = "ujjwal-s3-bucket"
    key            = "tfstate/ec2/ec2.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "tfstate-table"
  }
  required_version = "~> 1.0.0"
}
