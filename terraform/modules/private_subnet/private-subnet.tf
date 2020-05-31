#--------------------------------------------------------------
# This module creates all resources necessary for a private
# subnet
#--------------------------------------------------------------

variable "name"            { default = "private"}
variable "vpc_id"          { }
variable "cidrs"           { }
variable "azs"             { }
variable "nat_gateway_ids" { }
variable "tags"            { default= { } }

resource "aws_subnet" "private" {
  count             = length(split(",", var.cidrs))
  vpc_id            = var.vpc_id
  cidr_block        = element(split(",", var.cidrs), count.index)
  availability_zone = element(split(",", var.azs), count.index)
  tags = merge( var.tags, map("name", "${var.name}.${element(split(",", var.azs), count.index)}"))
  lifecycle { create_before_destroy = true }
}

resource "aws_route_table" "private" {
  count  = length(split(",", var.cidrs))
  vpc_id = var.vpc_id
  tags   = merge( var.tags, map("name", "${var.name}.${element(split(",", var.azs), count.index)}"))
  lifecycle { create_before_destroy = true }
}

resource "aws_route" "nat_gateway_id" {
    count  = length(split(",", var.cidrs))
    route_table_id = element(aws_route_table.private.*.id, count.index)
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = element(split(",", var.nat_gateway_ids), count.index)
    depends_on = [aws_route_table.private]
}

resource "aws_route_table_association" "private" {
  count          = length(split(",", var.cidrs))
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)

  lifecycle { create_before_destroy = true }
}

output "subnet_ids" { value = join(",", aws_subnet.private.*.id) }
output "route_table_ids" { value = join(",", aws_route_table.private.*.id) }
