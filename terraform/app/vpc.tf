module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "${local.application}-${var.env}-vpc"
  cidr = "${var.vpc_cidr_prefix}.0.0/18"

  azs                  = ["${local.region}a", "${local.region}b", "${local.region}c"]
  public_subnets       = ["${var.vpc_cidr_prefix}.0.0/24", "${var.vpc_cidr_prefix}.1.0/24", "${var.vpc_cidr_prefix}.2.0/24"]
  private_subnets      = ["${var.vpc_cidr_prefix}.3.0/24", "${var.vpc_cidr_prefix}.4.0/24", "${var.vpc_cidr_prefix}.5.0/24"]
  database_subnets     = ["${var.vpc_cidr_prefix}.7.0/24", "${var.vpc_cidr_prefix}.8.0/24", "${var.vpc_cidr_prefix}.9.0/24"]
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true
  external_nat_ip_ids  = [aws_eip.noco_aws_eip.id]
  reuse_nat_ips        = true

  tags = local.tags
}

resource "aws_eip" "noco_aws_eip" {
  depends_on  = [module.vpc.igw_id]
  vpc         = true
  tags        = local.tags
}

resource "aws_route_table" "internet_gateway" {
  vpc_id = module.vpc.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = module.vpc.igw_id
  }
}

resource "aws_route_table" "nat_gateway" {
  vpc_id = module.vpc.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = module.vpc.natgw_ids[0]
  }
}