terraform {
  backend "s3" {
    bucket       = "adminforge-terraform-state-872450837551-eu-west-2"
    key          = "adminforge/terraform.tfstate"
    region       = "eu-west-2"
    use_lockfile = true
    encrypt      = true
  }
}