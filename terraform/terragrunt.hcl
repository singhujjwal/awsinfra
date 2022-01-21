remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
   bucket         = "ujjwal-tf-bucket"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "tfstate-table"
  }
  disable_init = tobool(get_env("TERRAGRUNT_DISABLE_INIT", "false"))
}