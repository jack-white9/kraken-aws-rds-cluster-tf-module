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

  # cluster properties
  cluster_identifier       = "kraken-aurora-cluster"
  engine                   = "aurora-postgresql"
  availability_zones       = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  database_name            = "kraken_database"
  master_username          = "foo"
  master_password          = "barbarbar"
  snapshot_before_deletion = true

  # cluster networking properties
  vpc_id          = module.vpc.vpc_id
  security_groups = [module.vpc.default_security_group_id]
  security_group_rules = [{
    type      = "ingress",
    from_port = 5432,
    to_port   = 5432,
    protocol  = "tcp",
    self      = true
  }]
  subnet_ids = module.vpc.private_subnets

  # instance properties
  read_instance_class  = "db.t3.medium"
  write_instance_class = "db.t3.medium"
}
