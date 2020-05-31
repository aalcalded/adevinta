
# VPC
output "vpc_id"                                 { value = module.vpc.vpc_id }
output "vpc_cidr"                               { value = module.vpc.vpc_cidr }

# Subnets
output "public_subnet_id"                       { value = module.public_subnet.subnet_ids }
output "app_subnet"                             { value = module.app_subnet.subnet_ids }
output "backend_subnet"                         { value = module.backend_subnet.subnet_ids }

# Route Tables
output "public_route_table_id"                  { value = module.public_subnet.route_table_ids }
output "app_route_table_id"                     { value = module.app_subnet.route_table_ids }
output "backend_route_table_id"                 { value = module.backend_subnet.route_table_ids }

# Route53
output "dns_public_name"                        { value = module.route53.dns_public_name }
output "dns_public_zone_id"                     { value = module.route53.dns_public_zone_id }
output "dns_private_name"                       { value = module.route53.dns_private_name }
output "dns_private_zone_id"                    { value = module.route53.dns_private_zone_id }

# Bastion
output "bastion_user"                           { value = module.bastion.user }
output "bastion_private_ip"                     { value = module.bastion.private_ip }
output "bastion_public_ip"                      { value = module.bastion.public_ip }
output "bastion_sg_id"                          { value = module.bastion.sg_id }

# DDBB
output "ddbb_id"                                { value = module.bbdd.id }
output "ddbb_sg_id"                             { value = module.bbdd.sg_id } 

#Webserver
output "webserver_elb_sg_id"                    { value = module.webserver.elb_sg_id }
output "webserver_webserver_sg_id"              { value = module.webserver.webserver_sg_id }
output "webserver_lc_blue_id"                   { value = module.webserver.lc_blue_id}
output "webserver_asg_blue_id"                  { value = module.webserver.asg_blue_id }
output "webserver_lc_green_id"                  { value = module.webserver.lc_green_id }
output "webserver_asg_green_id"                 { value = module.webserver.asg_green_id }