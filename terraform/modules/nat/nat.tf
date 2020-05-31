#--------------------------------------------------------------
# This module creates all resources necessary for NAT
#--------------------------------------------------------------

variable "name"              { default = "nat" }
variable "azs"               { }
variable "public_subnet_ids" { }
variable "tags"              { }

resource "aws_eip" "nat" {
  count = length(split(",", var.azs))
  vpc   = true
  lifecycle { create_before_destroy = true }
}

resource "aws_nat_gateway" "nat" {
  count         = length(split(",", var.azs))
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(split(",", var.public_subnet_ids), count.index)
  tags          = merge( var.tags, map("name", var.name))
  lifecycle { create_before_destroy = true }
}

output "nat_gateway_ids" { value = join(",", aws_nat_gateway.nat.*.id) }
