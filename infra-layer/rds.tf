module "rds_master" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.10.0"
  
  identifier = "${local.name}-rds-master"
}

module "rds_replica" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.10.0"
  
  identifier = "${local.name}-rds-replica"
}