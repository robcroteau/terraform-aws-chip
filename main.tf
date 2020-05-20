provider "aws" {
  region = "us-west-1"
}

terraform {
  backend "s3" {
    bucket = "tfe-chip-terraform-state"
    key    = "tfe/terraform.tfstate"
    region = "us-west-1"
  }
}

module "tfe_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.33.0"

  cidr = "10.0.0.0/16"
  public_subnets = ["10.0.101.0/24","10.0.102.0/24"]
  private_subnets = ["10.0.103.0/24", "10.0.104.0/24"]
  database_subnets = ["10.0.105.0/24", "10.0.106.0/24"]
  name = "tfe-chip"
  create_database_subnet_route_table = true
  azs =["us-west-1a", "us-west-1b"]
}



module "route53_public_zone" {
  source  = "QuiNovas/route53-public-zone/aws"
  version = "3.0.1"
  name = "nowhere.com."
}

# resource "tls_private_key" "aws_ssh_key" {
#   algorithm = "RSA"
#   rsa_bits  = 2048
# }

# resource "aws_key_pair" "aws_ssh_key" {
#   key_name   = "${random_id.project_name.hex}-ssh-key"
#   public_key = "${tls_private_key.aws_ssh_key.public_key_openssh}"
# }

# resource "local_file" "private_key" {
#     content     = "${tls_private_key.aws_ssh_key.private_key_pem}"
#     filename = "${path.module}/private.pem"
# }

# resource "tls_self_signed_cert" "example" {
#   key_algorithm   = "RSA"
#   private_key_pem = tls_private_key.aws_ssh_key.private_key_pem

#   subject {
#     common_name  = "example.com"
#     organization = "ACME Examples, Inc"
#   }

#   validity_period_hours = 12

#   allowed_uses = [
#     "key_encipherment",
#     "digital_signature",
#     "server_auth",
#   ]
# }

# resource "aws_acm_certificate" "cert" {
#   private_key      = "${tls_private_key.aws_ssh_key.private_key_pem}"
#   certificate_body = "${tls_self_signed_cert.example.cert_pem}"
# }


module "tfe" {
  source = "git::git@github.com:hashicorp/terraform-chip-tfe-is-terraform-aws-ptfe-v4-quick-install.git"

  friendly_name_prefix       = "chip"
  common_tags                = {
                                 "Environment" = "Test"
                                 "Tool"        = "Terraform"
                                 "Owner"       = "Rob Croteau"
                               }
  tfe_hostname               = "my-tfe-instance.nowhere.com"
  tfe_license_file_path      = "./terraform-chip.rli"
  tfe_release_sequence       = "414"
  tfe_initial_admin_username = "tfe-local-admin"
  tfe_initial_admin_email    = "tfe-admin@nowhere.com"
  tfe_initial_admin_pw       = "ThisAintSecure123!"
  tfe_initial_org_name       = "nowhere"
  tfe_initial_org_email      = "tfe-admins@nowhere.com"
  vpc_id                     = "vpc-0c5c185dbe89f6485"
  alb_subnet_ids             = ["subnet-03ef6995b17c961bd", "subnet-03757c537c761b2ea"]
  ec2_subnet_ids             = ["subnet-04da31fb33a23f58f", "subnet-007f2c41ef055ab3a"]
  tls_certificate_arn        = "arn:aws:acm:us-west-1:066057276226:certificate/fae8b649-5cd6-4876-9c99-b9be5b33712d"
  route53_hosted_zone_name   = "nowhere.com."
  kms_key_arn                = "arn:aws:kms:us-west-1:066057276226:key/11edc15e-d40d-4983-a11b-cb726287bff0"
  ingress_cidr_alb_allow     = ["0.0.0.0/0"]
  ingress_cidr_ec2_allow     = ["98.13.164.117/32"] # my workstation IP
  ssh_key_pair               = "tfe-chip-keypair"
  rds_subnet_ids             = ["subnet-03dc11f1a5530e94d", "subnet-0a800fbd15ebbe9a1"]
}