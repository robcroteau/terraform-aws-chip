/*********************
 VPC Variables
**********************/
variable "name" {
  description = "Name of the VPC"
  default = "vpc"
}

variable "vpc_cidr" {
  description = "CIDR Range for VPC"
  default = "192.168.0.0/16"
}

variable "private_subnets" {
    description = "CIDR Ranges for private subnets"
    type = list
    default = ["192.168.1.0/24", "192.168.2.0/24"]
}

variable "public_subnets" {
    description = "CIDR Ranges for public subnets"
    type = list
    default = ["192.168.101.0/24", "192.168.102.0/24"]
}

variable "database_subnets" {
    description = "CIDR Ranges for database subnets"
    type = list
    default = ["192.168.201.0/24", "192.168.202.0/24"]
}


/***************************
  TFE Variables
****************************/

variable "friendly_name_prefix" {
    description = "Friendly name to prefix created resources"
    default = "tfe"
}

variable "tfe_hostname" {
    description = "Name of the TFE frontend URL"
    default = "tfe.rcroteau.com"
}

variable "tfe_license_file" {
    description = "Path location to the Terraform Enterprise License file"
    default = "terraform-chip.rli"
  
}


