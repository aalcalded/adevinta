#Project
variable "project_name" {
  description = "Name of this project"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map
  default     = { }
}

variable "az_a" {
  description = "AWS availability zone A"
  type        = string
}

variable "az_b" {
  description = "AWS availability zone B"
  type        = string
}

variable "office_cidr" {
  description = "IP office"
  type        = string
}

#Bastion
variable "bastion_instance_type" {
  description = "Bastion EC2 instance type"
  type        = string
}

variable "bastion_instance_ami" {
  description = "Bastion EC2 instance AMI"
  type        = string
}

#Webserver
variable "enable_green_webserver" {
  description = "Enable green deploy asg webserver"
  type        = string
  default     = false
}
variable "webserver_green_ami" {
  description = "AMI ID for webserver green deployment"
  type        = string
  default     = ""
}
variable "webserver_green_type" {
  description = "Instance typr for webserver green deployment"
  type        = string
  default     = ""
}