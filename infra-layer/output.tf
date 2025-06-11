output "vpc_name" {
  value = module.vpc.name
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "database_subnets" {
  value = module.vpc.database_subnets
}

output "database_subnet_group_name" {
  value = module.vpc.database_subnet_group_name
}

output "database_subnets_route_table_association_ids" {
  value = module.vpc.database_route_table_association_ids
}