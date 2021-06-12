owner = "Ujjwal Singh"
vpc_name = "ujjwal-default-vpc"
vpc_cidr = "10.0.0.0/16"
vpc_private_subnet_list = ["10.0.0.0/18", "10.0.64.0/18", "10.0.128.0/18"]
vpc_public_subnet_list = ["10.0.192.0/20", "10.0.208.0/20", "10.0.224.0/20"]
vpc_internal_domain_name = "ec2.internal"
dns_server_list = ["AmazonProvidedDNS"]


#aws ec2 create-vpc --cidr-block 10.0.0.0/16