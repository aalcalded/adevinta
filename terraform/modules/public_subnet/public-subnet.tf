#--------------------------------------------------------------
# This module creates all resources necessary for a public
# subnet
#--------------------------------------------------------------

variable "name"                { default = "public" }
variable "vpc_id"              { }
variable "cidrs"               { }
variable "azs"                 { }
variable "internet_gateway_id" { }
variable "tags"                { default= { } }

resource "aws_subnet" "public" {
  count             = length(split(",", var.cidrs))
  vpc_id            = var.vpc_id
  cidr_block        = element(split(",", var.cidrs), count.index)
  availability_zone = element(split(",", var.azs), count.index)
  tags              = merge( var.tags, map("name", "${var.name}.${element(split(",", var.azs), count.index)}"))
  lifecycle { create_before_destroy = true }

  map_public_ip_on_launch = true
}

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id
  tags   = merge( var.tags, map("name", "${var.name}"))
}

resource "aws_route" "internet_gateway_id" {
    count  = length(split(",", var.cidrs))
    route_table_id = element(aws_route_table.public.*.id, count.index)
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = element(split(",", var.internet_gateway_id), count.index)
    depends_on = [aws_route_table.public]
}

resource "aws_route_table_association" "public" {
  count          = length(split(",", var.cidrs))
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

output "subnet_ids" { value = join(",", aws_subnet.public.*.id) }
output "route_table_ids" { value = join(",", aws_route_table.public.*.id) }
