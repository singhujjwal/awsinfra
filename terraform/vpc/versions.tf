terraform {
  required_version = "0.12.29"
}

provider "aws" {
  version = "3.11.0"
  region  = var.region
}
