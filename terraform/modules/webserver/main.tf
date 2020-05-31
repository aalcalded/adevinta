#-------------------------------------------------------------------------------------------
# This module defines a Green/Blue Deploymen Web server together with its SG and its LB
#-------------------------------------------------------------------------------------------


#########
# IAM
##########

resource "aws_iam_role" "webserver" {
    name               = var.name
    assume_role_policy = var.assume_role_policy
}

resource "aws_iam_role_policy" "logging" {
  name = "${var.name}-logging"
  role = aws_iam_role.webserver.id
  policy = var.log_role_policy
}  

resource "aws_iam_instance_profile" "webserver" {
    name  = aws_iam_role.webserver.name
    path  = "/"
    role = aws_iam_role.webserver.name
    depends_on = [ aws_iam_role.webserver ]
}

##########
# SG
##########

resource "aws_security_group" "webserver" {
  name   = "${var.name}-SG"
  vpc_id = var.vpc_id
  lifecycle { create_before_destroy = true }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_security_group" "webserver_elb" {
  name   = "${var.name}-public-elb-SG"
  vpc_id = var.vpc_id
  lifecycle { create_before_destroy = true }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

   tags = var.tags
}

##########
# SG Rules
##########

resource "aws_security_group_rule" "allow_webserver_elb_cidr" {
    type = "ingress"
    from_port = var.elb_lb_port
    to_port = var.elb_lb_port
    protocol = "tcp"
    cidr_blocks = [ var.ingress_tcp_cidr  ]

    security_group_id = aws_security_group.webserver_elb.id
}

resource "aws_security_group_rule" "allow_elb2server" {
    type = "ingress"
    from_port = var.elb_lb_port
    to_port = var.elb_instance_port
    protocol = "tcp"

    security_group_id = aws_security_group.webserver.id
    source_security_group_id = aws_security_group.webserver_elb.id
}

###################
# Cloud Watch Logs
###################

resource "aws_cloudwatch_log_group" "webserver" {
  name              = var.cloudwatch_group_name
  retention_in_days = var.cloudwatch_retention_days
  tags              = var.tags
}