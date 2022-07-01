module "redis" {
  source = "cloudposse/elasticache-redis/aws"
  version = "0.44.0"

  name                       = "${local.application}-redis-${var.env}"
  security_group_name        = ["${local.application}-redis-${var.env}-sg"]
  zone_id                    = local.zone_id
  vpc_id                     = module.vpc.vpc_id
  allowed_security_group_ids = [aws_security_group.sg_ecs.id]
  subnets                    = module.vpc.private_subnets
  cluster_size               = var.redis_cluster_size
  instance_type              = var.redis_instance_type
  apply_immediately          = true
  automatic_failover_enabled = var.redis_automatic_failover_enabled
  engine_version             = 6.2
  family                     = "redis6.x"
  tags                       = local.tags
}