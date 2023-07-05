
output "private_sg" {
  value = aws_security_group.private_sg.id
  description = "Private security group id"
}

output "public_sg" {
  value = aws_security_group.public_sg.id
  description = "Private security group id"
}