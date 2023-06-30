
output "public_route_table_id" {
  value = aws_route_table.public[0].id
  description = "AWS Route Table ID, to enable aditional routes to be added externally"
}

