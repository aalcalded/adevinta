#-----------------------------------------------------------------------
# This module defines a RDS
#-----------------------------------------------------------------------

variable "name"                       { }
variable "vpc_id"                     { }
variable "allocated_storage"          { default = 5 }
variable "engine"                     { }
variable "engine_version"             { }
variable "storage_type"               { default = "standard" }
variable "parameter_group_family"     { }
variable "instance_type"              { }
variable "multi_az"                   { default = false }         
variable "tags"                       { }
variable "db_username"                { }
variable "secretsmanager_arn"         { }
variable "subnets_ids"                { default = [] }
variable "apply_immediately"          { default =true }
variable "backup_window"              { default = "04:00-04:30" }
variable "backup_retention_period"    { default =30 }
variable "maintenance_window"         { default ="Mon:00:00-Mon:03:00" }
variable "route53_zone_id"            { }
variable "route53_zone_name"          { }



##########
# SG
##########

resource "aws_security_group" "bbdd" {
  name   = "${var.name}-bbdd-SG"
  vpc_id =  var.vpc_id
  lifecycle { create_before_destroy = true }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags  = var.tags

}

#################
# Subnet Group
#################

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = var.name
  subnet_ids = var.subnets_ids
}

########################
# DDBB Parameter Group
########################

resource "aws_db_parameter_group" "rds_parameter_group" {
  name   = var.name
  family = var.parameter_group_family
}
###############
# DDBB Secret
#################

data "aws_secretsmanager_secret" "db" {
  arn = var. secretsmanager_arn
}

data "aws_secretsmanager_secret_version" "db" {
  secret_id = data.aws_secretsmanager_secret.db.id
}
##########
# RDS
##########

resource "aws_db_instance" "rds_instance" {
  
  name                      = "helloworld"
  identifier                = var.name
  instance_class            = var.instance_type
  allocated_storage         = var.allocated_storage
  apply_immediately         = var.apply_immediately
  db_subnet_group_name      = aws_db_subnet_group.rds_subnet_group.id
  engine                    = var.engine
  engine_version            = var.engine_version
  multi_az                  = var.multi_az
  parameter_group_name      = aws_db_parameter_group.rds_parameter_group.id
  username                  = var.db_username
  password                  = jsondecode(data.aws_secretsmanager_secret_version.db.secret_string)["rds_postgres"]
  storage_type              = var.storage_type
  tags                      = var.tags
  final_snapshot_identifier = "${var.name}-final-snapshot"
  vpc_security_group_ids    = [aws_security_group.bbdd.id]
  backup_window             = var.backup_window
  backup_retention_period   = var.backup_retention_period
  maintenance_window        = var.maintenance_window

  lifecycle {
    create_before_destroy = true
    ignore_changes = [password]
  }
}

##################
# Route53 Record
##################

resource "aws_route53_record" "bbdd" {
   zone_id = var.route53_zone_id
   name = var.route53_zone_name
   type = "CNAME"
   ttl = "300"
   records = [ aws_db_instance.rds_instance.address]
}


##########
# Outputs
##########

output "sg_id"                 { value = aws_security_group.bbdd.id }
output "id"                    { value = aws_db_instance.rds_instance.id } 
