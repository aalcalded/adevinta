#--------------------------------------------------------------
# This module creates all resources necessary for a Bastion
# host
#--------------------------------------------------------------

variable "name"               { default = "bastion" }
variable "vpc_id"             { }
variable "vpc_cidr"           { }
variable "region"             { }
variable "public_subnet_id"   { }
variable "key_name"           { }
variable "instance_ami"       { }
variable "instance_type"      { }
variable "ingress_tcp_cidr"   { }
variable "assume_role_policy" { }
variable "tags"               { }


resource "aws_iam_role" "bastion" {
    name               = var.name
    assume_role_policy = var.assume_role_policy
    lifecycle { create_before_destroy = true }
}

resource "aws_iam_instance_profile" "bastion" {
    name  = aws_iam_role.bastion.name
    path  = "/"
    role = aws_iam_role.bastion.name
    depends_on = [ aws_iam_role.bastion ]
    lifecycle { create_before_destroy = true }
}

resource "aws_security_group" "bastion" {
  name        = var.name
  vpc_id      = var.vpc_id
  description = "Bastion security group"

  tags        = var.tags
  lifecycle { create_before_destroy = true }

  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [ var.ingress_tcp_cidr ]

  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = var.instance_ami
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = [ aws_security_group.bastion.id ]
  iam_instance_profile        = aws_iam_instance_profile.bastion.name
  associate_public_ip_address = true

  tags        =  merge( var.tags, map("Name", var.name))
  lifecycle { create_before_destroy = true }
}

output "user"       { value = "ec2-user" }
output "private_ip" { value = aws_instance.bastion.private_ip }
output "public_ip"  { value = aws_instance.bastion.public_ip }
output "sg_id"         { value = aws_security_group.bastion.id }