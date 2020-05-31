# WORKSPACE VARS

locals {
  context_variables = {
    pro = {
      vpc_cidr                      = "10.11.0.0/16"
      public_subnet_a               = "10.11.1.0/24"
      public_subnet_b               = "10.11.2.0/24"
      app_subnet_a                  = "10.11.3.0/24"
      app_subnet_b                  = "10.11.4.0/24"
      backend_subnet_a              = "10.11.5.0/24"
      backend_subnet_b              = "10.11.6.0/24"
      webserver_instance_type       = "t2.micro"
      webserver_instance_ami        = "ami-0971798de8af14c0b"
      bbdd_engine                   = "postgres"
      bbdd_engine_version           = "9.6.1"
      bbdd_parameter_group_family   = "postgres9.6"
      bbdd_instance_type            = "db.t2.micro"
      bbdd_multi_az                 =  true
      bbdd_port                     = "5432"
      bbdd_username                 = "postgres"
      bbdd_secretsmanager_arn       = "arn:aws:secretsmanager:eu-west-1:420506590284:secret:adevinta/pro/postgres-V0Mgd5"

    }
  }
}
locals {
  workspaces          = merge(local.context_variables)
  workspace           = merge(local.workspaces[terraform.workspace])
  tags                = merge( var.tags, map("environment", terraform.workspace))
  name                = "${terraform.workspace}-${var.project_name}"
  key_name            = "${terraform.workspace}-${var.project_name}"
  dns_name_private    = "${terraform.workspace}.${var.project_name}.local"
  dns_name_public     = "${terraform.workspace}.${var.project_name}.ext"
}
