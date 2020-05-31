#--------------------------------------------------------------
# This module creates all resources necessary for an IGW
#--------------------------------------------------------------

variable "name"   { default = "igw" }
variable "vpc_id" { }
variable "tags"   { }


resource "aws_internet_gateway" "public" {
  vpc_id  = var.vpc_id
  tags    = merge( var.tags, map("name", var.name))
}

output "gateway_id" { value = aws_internet_gateway.public.id }
