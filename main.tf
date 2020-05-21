provider "aws" {
  region = "us-west-1"
}

resource "random_id" "project_name" {
  byte_length = 3
}

data "aws_availability_zones" "azs" {
  state = "available"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc
  cidr = var.vpc_cidr

  azs             = [data.aws_availability_zones.azs.names[0], data.aws_availability_zones.azs.names[1]]

  private_subnets  = var.private_subnets
  public_subnets  =  var.public_subnets
  database_subnets = var.database_subnets

  enable_nat_gateway = true
}

resource "tls_private_key" "aws_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "aws_ssh_key" {
  key_name   = "${random_id.project_name.hex}-ssh-key"
  public_key = "${tls_private_key.aws_ssh_key.public_key_openssh}"
}

resource "local_file" "private_key" {
    content     = "${tls_private_key.aws_ssh_key.private_key_pem}"
    filename = "${path.module}/private.pem"
}

resource "tls_self_signed_cert" "example" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.aws_ssh_key.private_key_pem

  subject {
    common_name  = "rcroteau.com"
    organization = "ACME Examples, Inc"
  }

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "cert" {
  private_key      = "${tls_private_key.aws_ssh_key.private_key_pem}"
  certificate_body = "${tls_self_signed_cert.example.cert_pem}"
}

module "tfe" {
  source = "git@github.com:hashicorp/terraform-chip-tfe-is-terraform-aws-ptfe-v4-quick-install.git"

  friendly_name_prefix       = var.friendly_name_prefix
  tfe_hostname               = var.tfe_hostname
  tfe_license_file_path      = var.tfe_license_file_path
  vpc_id                     = module.vpc.vpc_id
  alb_subnet_ids             = module.vpc.public_subnets
  ec2_subnet_ids             = module.vpc.private_subnets
  rds_subnet_ids             = module.vpc.database_subnets
  tls_certificate_arn        = aws_acm_certificate.cert.arn
}