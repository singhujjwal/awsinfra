
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_availability_zones" "available" {
  state = "available"
}

output "az_id" {

  value = data.aws_availability_zones.available
  
}

data "aws_subnet" "selected" {
  availability_zone = "ap-south-1a"
  // availability_zone_id = "aps1-az1"
  filter {
    name   = "tag:Name"
    values = ["Public-Subnet"]
  }
}

//By following count you can't delete a selected instance as you dont 
// know which will be chosen and you might get land in a
// problematic situation



# resource "aws_instance" "web" {
#   count = 1
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = "t2.micro"

#   subnet_id = data.aws_subnet.selected.id

#   tags = {
#     Name = "HelloWorld1"
#   }
# }

resource "aws_instance" "web" {
  for_each = toset(["one"])
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  subnet_id = data.aws_subnet.selected.id

  tags = {
    Name = "HelloWorld1-${each.key}-${each.value}"
  }
}
