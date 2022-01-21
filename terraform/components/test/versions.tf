terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      //This is a major  version upgrade need to consider what to upgrade from what 
      // version
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0.0"
}


provider "aws" {
  region = "ap-south-1"
  // Strictly No No
  // access_key = "my-access-key"
  // secret_key = "my-secret-key"

  // export AWS_ACCESS_KEY_ID="anaccesskey"
  // export AWS_SECRET_ACCESS_KEY="asecretkey"
  // export AWS_DEFAULT_REGION="us-west-2"
}
