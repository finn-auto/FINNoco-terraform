resource "aws_route53_record" "server1-record" {
  zone_id = local.zone_id
  name    = "${var.subdomain}.${local.domain_name}"
  type    = "A"
  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}