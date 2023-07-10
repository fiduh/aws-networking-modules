################################################################################
# Internet Gateway
################################################################################
output "igw_id" {
  value = try(aws_internet_gateway.igw[0].id, null)
  description = "ID of the Internet Gateway"
}

output "igw_arn" {
  value = try(aws_internet_gateway.igw[0].arn, null)
  description = "ARN of the Internet Gateway"
}

################################################################################
# Publiс Subnets
################################################################################


################################################################################
# Private Subnets
################################################################################
output "private_subnets" {
  description = "List of IDs of Private Subnets"
  value = try(values(aws_subnet.private)[*].id, null)
}

output "private_subnet_arns" {
  description = "List of ARNs of Private Subnets"
  value = try(values(aws_subnet.private)[*].arn, null)
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = try(aws_route_table.private-rt[*].id, null)
}

output "private_route_table_association_ids" {
  description = "List of IDs of the private route table association"
  value       = try(aws_route_table_association.private_rt_association[*].id, null)
}