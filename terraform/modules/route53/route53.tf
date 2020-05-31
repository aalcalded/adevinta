#--------------------------------------------------------------
# This module creates all resources necessary for a Route53
#--------------------------------------------------------------

variable "dns_name_public"     { default = "public" }
variable "dns_name_private"    { default = "public" }
variable "vpc_id"              { }
variable "tags"                { default= { } }

resource "aws_route53_zone" "public" {
  name   = var.dns_name_public
  tags   = var.tags
}
resource "aws_route53_zone" "private" {
  name   = var.dns_name_private
  vpc {
    vpc_id = var.vpc_id
  }
  tags   = var.tags
}


####################
# Outputs          #
####################

output "dns_public_name"       { value = "${aws_route53_zone.public.name}" }
output "dns_public_zone_id"    { value = "${aws_route53_zone.public.zone_id}" }
output "dns_private_name"       { value = "${aws_route53_zone.private.name}" }
output "dns_private_zone_id"    { value = "${aws_route53_zone.private.zone_id}" }


