###########
# Outputs #
###########
output "elb_sg_id"                  { value = aws_security_group.webserver_elb.id }
output "webserver_sg_id"            { value = aws_security_group.webserver.id }
output "lc_blue_id"                 { value = aws_launch_configuration.webserver_blue.id }
output "asg_blue_id"                { value = aws_autoscaling_group.webserver_blue.id }
output "lc_green_id"                { value = aws_launch_configuration.webserver_green.*.id }
output "asg_green_id"               { value = aws_autoscaling_group.webserver_green.*.id }