##########
# Global #
##########
variable "name"                                     { }
variable "vpc_id"                                   { }


########
# ELB  #
########
variable "elb_subnet_id"                            { }
variable "elb_instance_port"                        { default = 8000}
variable "elb_instance_protocol"                    { default = "http" }
variable "elb_lb_port"                              { default = 80 }
variable "elb_lb_protocol"                          { default = "http" }
variable "elb_healthy_threshold"                    { default = 2 }
variable "elb_unhealthy_threshold"                  { default = 2 }
variable "elb_timeout"                              { default = 3 }
variable "elb_target"                               { default = "TCP:8000" }
variable "elb_cross_zone"                           { default = true }
variable "elb_idle_timeout"                         { default = 400 }
variable "elb_connection_draining"                  { default = true }
variable "elb_draining_timeout"                     { default = 400 }
variable "elb_interval"                             { default = 30 }
variable "ingress_tcp_cidr"                         { }


###########################
# Launch Configuration    #
###########################
variable "webserver_ami"                            { }
variable "webserver_type"                           { }
variable "webserver_green_ami"                      { default = ""}
variable "webserver_green_type"                     { default = ""}
variable "key_name"                                 { }
variable "assume_role_policy"                       { }
variable "log_role_policy"                          { }
variable "instance_subnet_id"                       { }
variable "tags"                                     { }


########################
# AutoScaling Group    #
########################
variable "asg_min_size"                                 { default = 1}
variable "asg_desired_size"                             { default = 1}
variable "asg_max_size"                                 { default = 2}
variable "asg_grace_period"                             { default = 300}
variable "asg_health_type"                              { default = "ELB" }
variable "asg_termination_policies"                     { default = [ "ClosestToNextInstanceHour" ] }

#############
# Route53   #
#############

variable "route53_zone_id"                          { }
variable "route53_zone_name"                        { }
variable "route53_weighted_policy"                  { default = 10 }
variable "route53_weighted_policy_green"            { default = 0 }

########################
# Cloud Watch Logs     #
########################
variable "cloudwatch_group_name"                    { }
variable "cloudwatch_retention_days"                { default = 30}