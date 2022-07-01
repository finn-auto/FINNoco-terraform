module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name = local.domain_name
  zone_id     = local.zone_id

  subject_alternative_names = [
    "${var.subdomain}.${local.domain_name}",
  ]

  wait_for_validation = true

  tags        = local.tags
}