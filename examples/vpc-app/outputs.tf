output "aws_subnet_public" {
  value = module.vpc-app-mgmt-datastore.aws_subnet_public
}

output "public_subnets_ids" {
  value = module.vpc-app-mgmt-datastore.public_subnets_ids
}

/*
output "private_subnets_ids" {
  value = module.vpc-app-mgmt-datastore.private_subnets_ids
}

*/