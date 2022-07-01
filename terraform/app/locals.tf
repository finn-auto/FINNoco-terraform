locals {
  application = "nocodb"
  iac         = "terraform"
  region      = "eu-central-1"
  key_name    = "var.unique_key_name"
  domain_name = "var.domain_name"
  zone_id     = "var.zone_id"

  tags = {
    maintainer  = var.maintainer
    application = local.application
    iac         = local.iac
    env         = var.env
  }

  is_production = length(regexall("production.*", var.env)) > 0
}