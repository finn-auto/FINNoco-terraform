module "aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "5.2.0"

  name                  = "${local.application}-${var.env}-postgres"
  engine                = "aurora-postgresql"
  engine_version        = "12.8"
  instance_type         = var.db_instance_class
  instance_type_replica = var.db_instance_replica_class

  deletion_protection     = true
  copy_tags_to_snapshot   = true
  backup_retention_period = 30

  vpc_id                  = module.vpc.vpc_id
  db_subnet_group_name    = module.vpc.database_subnet_group_name
  allowed_cidr_blocks     = module.vpc.private_subnets_cidr_blocks
  create_security_group   = true
  allowed_security_groups = [aws_security_group.sg_ecs.id]

  replica_count          = var.db_instance_count
  database_name          = "main"
  username               = "db_user"
  password               = random_password.db_password.result
  create_random_password = false

  apply_immediately   = true
  skip_final_snapshot = false

  db_parameter_group_name         = aws_db_parameter_group.instance_param_group.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.cluster_param_group.id
  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = local.tags
}

resource "random_password" "db_password" {
  length  = 24
  special = false
}

resource "aws_rds_cluster_parameter_group" "cluster_param_group" {
  name        = "${local.application}-cluster-parameter-group-${var.env}"
  family      = "aurora-postgresql12"
  description = "${local.application}-cluster-parameter-group-${var.env}"
  tags        = local.tags
}

resource "aws_db_parameter_group" "instance_param_group" {
  name        = "${local.application}-instance-parameter-group-${var.env}"
  family      = "aurora-postgresql12"
  description = "${local.application}-instance-parameter-group-${var.env}"
  tags        = local.tags
}