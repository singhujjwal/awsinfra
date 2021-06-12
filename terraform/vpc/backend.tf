# Add locking mechanism later
terraform {
  backend "s3" {
    bucket = "ujjwal-s3-bucket"
    key    = "vpc"
    region = "ap-south-1"
  }
  required_version = "~> 1.0.0"
}
