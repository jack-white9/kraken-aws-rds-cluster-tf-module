locals {
  azs      = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  vpc_cidr = "10.0.0.0/16"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "kraken-example-vpc"
  cidr = local.vpc_cidr

  azs              = local.azs
  public_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 3)]
  database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 6)]
}


module "aws_rds_cluster" {
  source = "../../"

  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  security_groups = [module.vpc.default_security_group_id]

  # optional properties for cost-saving (not intended for prod use – see README)
  write_instance_class = "db.t3.medium"
  read_instance_class  = "db.t3.medium"
}
