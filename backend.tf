terraform {
  backend "s3" {
    bucket = "tfe-chip-terraform-state"
    key    = "tfe/tfe/terraform.tfstate"
    region = "us-west-1"
  }
}