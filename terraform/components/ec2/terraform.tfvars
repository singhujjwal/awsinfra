vpc_id               = "vpc-09e60a39a92e4dbea"
subnet_id            = "subnet-0bc7f4a990a6309a3"
name                 = "masterjenkins"
region               = "ap-south-1"
master_instance_type = "t2.medium"
master_instance_ami  = "ami-041db4a969fe3eb68"
key_name             = "ujjwalAWS"
vpc_tfstate_bucket_name = "ujjwal-s3-bucket"
vpc_tfstate_bucket_key  = "tfstate/vpc/vpc.tfstate"
region                  = "ap-south-1"
public_subnets          = []
private_subnets         = []
vpc_id                  = "null"
key_pair_name = "ujjwal-aws-key.pem"
private_ssh_key_ssm_path = "private-key"

