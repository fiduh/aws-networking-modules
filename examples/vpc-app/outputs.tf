
output "private_sg" {
  value = module.vpc-app-mgmt-datastore.private_sg
  description = "Private security group id"
}

output "public_sg" {
  value = module.vpc-app-mgmt-datastore.public_sg
  description = "Private security group id"
}