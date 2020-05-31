# Project
project_name       = "adevinta"
region             = "eu-west-1"
tags = {
  project     = "adevinta"
  terraform   = "true"
}

# Subnets
az_a              = "eu-west-1a"
az_b              = "eu-west-1b"

office_cidr         = "93.176.157.142/32"

#Bastion
bastion_instance_type      = "t2.micro"
bastion_instance_ami       = "ami-0ea3405d2d2522162"
