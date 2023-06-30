
output "private_route_table_id" {
  value = module.vpc-app-mgmt-datastore.private_route_table_id
}


output "nat_gatway_id" {
  value = module.vpc-app-mgmt-datastore.nat_gatway_id
}