output "aws_subnet_public" {
  value = values(aws_subnet.public)[*].id
  description = "list of aws public subnets"
}

output "public_subnets_ids" {
  value = local.public_subnets_ids
}


/*
output "private_subnets_ids" {
  value = local.private_subnets_ids
}

*/