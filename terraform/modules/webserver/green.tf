variable "enable_green_webserver" {
  default = false
  type    = bool
}

##########
# ELB
##########

resource "aws_elb" "webserver_elb_green" {
  count                 = var.enable_green_webserver ? 1 : 0    
  name                  = "${var.name}-elb-green"
  subnets               = var.elb_subnet_id
  security_groups       = [ aws_security_group.webserver_elb.id ] 

  listener {
    instance_port       = var.elb_instance_port
    instance_protocol   = var.elb_instance_protocol
    lb_port             = var.elb_lb_port
    lb_protocol         = var.elb_lb_protocol
  }

  health_check {
    healthy_threshold       = var.elb_healthy_threshold
    unhealthy_threshold     = var.elb_unhealthy_threshold
    timeout                 = var.elb_timeout
    target                  = var.elb_target
    interval                = var.elb_interval
  }

  cross_zone_load_balancing   = var.elb_cross_zone
  idle_timeout                = var.elb_idle_timeout
  connection_draining         = var.elb_connection_draining
  connection_draining_timeout = var.elb_draining_timeout

  tags                         = merge(var.tags, map("Has_Toggle", var.enable_green_webserver))
}



############
# ROUTE53
############

resource "aws_route53_record" "webserver_green" {
  count     = var.enable_green_webserver ? 1 : 0    
  zone_id   = var.route53_zone_id
  name      = "application.${var.route53_zone_name}"
  type      = "A"

  alias {
    name                   = aws_elb.webserver_elb_green.0.dns_name
    zone_id                = aws_elb.webserver_elb_green.0.zone_id
    evaluate_target_health = true
  }

  weighted_routing_policy {
    weight = var.route53_weighted_policy_green
  }

  set_identifier = "green"
}

################
# AUTOSCALING
###############

resource "aws_launch_configuration" "webserver_green" {
  count                       = var.enable_green_webserver ? 1 : 0    
  name_prefix                 = var.name
  image_id                    = var.webserver_green_ami
  instance_type               = var.webserver_green_type
  security_groups             = [ aws_security_group.webserver.id ] 
  iam_instance_profile        = aws_iam_instance_profile.webserver.name
  key_name                    = var.key_name

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "webserver_green" {
  count                         = var.enable_green_webserver ? 1 : 0  
  name                          = "${var.name}-asg-green"
  min_size                      = var.asg_min_size
  desired_capacity              = var.asg_desired_size
  max_size                      = var.asg_max_size
  health_check_grace_period     = var.asg_grace_period
  health_check_type             = var.asg_health_type
  launch_configuration          = aws_launch_configuration.webserver_green[count.index].name
  vpc_zone_identifier           = [ var.instance_subnet_id ]
  load_balancers                = [ aws_elb.webserver_elb_green[count.index].name]
  tags                          = [
      map("key", "Name", "value", var.name, "propagate_at_launch", true),
      map("key", "set_identifier", "value", "green", "propagate_at_launch", true)
  ]

  lifecycle {
    create_before_destroy = true
  } 
}
