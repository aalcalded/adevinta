###############################################
# Aventia stack
###############################################


#################
# AWS Provider
#################

provider "aws" {
  version = "~> 2.0"
  region  = var.region
}

#############
# VPC
#############

module "vpc" {
  source = "../modules/vpc"
  name   = "${local.name}-vpc"
  cidr   = local.workspace["vpc_cidr"]
  tags   = local.tags
}

#############
# IGW
#############

module "igw" {
  source = "../modules/igw"
  name   = "${local.name}-igw"
  vpc_id = module.vpc.vpc_id
  tags   = local.tags
}

#############
# Subnets
#############

module "public_subnet" {
  source              = "../modules/public_subnet"
  name                = "${local.name}-public"
  vpc_id              = module.vpc.vpc_id
  cidrs               = "${local.workspace["public_subnet_a"]},${local.workspace["public_subnet_b"]}"   
  azs                 = "${var.az_a},${var.az_b}"
  internet_gateway_id = module.igw.gateway_id
  tags                = local.tags
}

module "app_subnet" {
  source          = "../modules/private_subnet"
  name            = "${local.name}-app"
  vpc_id          = module.vpc.vpc_id
  cidrs           = "${local.workspace["app_subnet_a"]},${local.workspace["app_subnet_b"]}"
  azs             = "${var.az_a},${var.az_b}"
  nat_gateway_ids = module.nat.nat_gateway_ids
  tags            = local.tags
}


module "backend_subnet" {
  source          = "../modules/private_subnet"
  name            = "${local.name}-backend"
  vpc_id          = module.vpc.vpc_id
  cidrs           = "${local.workspace["backend_subnet_a"]},${local.workspace["backend_subnet_b"]}"   
  azs             = "${var.az_a},${var.az_b}"
  nat_gateway_ids = module.nat.nat_gateway_ids
  tags            = local.tags
}

###########
# NAT GW  #  
###########

module "nat" {
  source            = "../modules/nat"
  name              = "${local.name}-nat"
  azs               = "${var.az_a},${var.az_b}"
  public_subnet_ids = module.public_subnet.subnet_ids
  tags              = local.tags
}

###########
# Route53 #
###########

module "route53" {
  source              = "../modules/route53"
  dns_name_public     = local.dns_name_public
  dns_name_private    = local.dns_name_private
  vpc_id              = module.vpc.vpc_id
  tags                = local.tags
}

############
# Bastion  #
############

module "bastion" {
  source             = "../modules/bastion"
  name               = "${local.name}-bastion"
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = module.vpc.vpc_cidr
  region             = var.region
  public_subnet_id   = element(split(",", module.public_subnet.subnet_ids),0)
  ingress_tcp_cidr   = var.office_cidr
  key_name           = local.key_name
  instance_type      = var.bastion_instance_type
  instance_ami       = var.bastion_instance_ami
  tags               = local.tags
  assume_role_policy = file("iam-policies/bastion-role.json")
}

############
#   App    #
############

module "webserver" {
  source                         = "../modules/webserver"
  name                           = "${local.name}-app"
  vpc_id                         = module.vpc.vpc_id
  ingress_tcp_cidr               = "0.0.0.0/0"
  instance_subnet_id             = element(split(",", module.app_subnet.subnet_ids),0)
  webserver_ami                  = local.workspace["webserver_instance_ami"]
  webserver_type                 = local.workspace["webserver_instance_type"]
  key_name                       = local.key_name
  tags                           = local.tags
  assume_role_policy             = file("./iam-policies/webserver-role.json")
  log_role_policy                = file("./iam-policies/log-policy.json")
  elb_subnet_id                  = split(",",module.public_subnet.subnet_ids)
  route53_zone_id                = module.route53.dns_public_zone_id
  route53_zone_name              = module.route53.dns_public_name
  cloudwatch_group_name          = local.name
  enable_green_webserver         = var.enable_green_webserver
  webserver_green_ami            = var.webserver_green_ami
  webserver_green_type           = "${var.webserver_green_type=="" ? local.workspace["webserver_instance_type"] : var.webserver_green_type}"
}


############
#   RDS    #
############

module "bbdd" {
  source                         = "../modules/rds"
  name                           = "${local.name}-postgres"
  vpc_id                         = module.vpc.vpc_id
  engine                         = local.workspace["bbdd_engine"]
  engine_version                 = local.workspace["bbdd_engine_version"]
  parameter_group_family         = local.workspace["bbdd_parameter_group_family"]
  instance_type                  = local.workspace["bbdd_instance_type"]
  multi_az                       = local.workspace["bbdd_multi_az"]
  db_username                    = local.workspace["bbdd_username"]
  secretsmanager_arn             = local.workspace["bbdd_secretsmanager_arn"]
  subnets_ids                    = split(",", module.backend_subnet.subnet_ids)
  tags                           = local.tags
  route53_zone_id                = module.route53.dns_private_zone_id
  route53_zone_name              = "database.${local.dns_name_private}"
}


##########
# SG Rules
##########

resource "aws_security_group_rule" "allow_app2bddd" {
    type = "ingress"
    from_port = local.workspace["bbdd_port"] 
    to_port = local.workspace["bbdd_port"] 
    protocol = "tcp"

    security_group_id = module.bbdd.sg_id
    source_security_group_id = module.webserver.webserver_sg_id
} 

resource "aws_security_group_rule" "allow_bastion2app" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"

    security_group_id =module.webserver.webserver_sg_id
    source_security_group_id = module.bastion.sg_id
}
