output "dynamodb_table_name" {
  value       = aws_dynamodb_table.basic-dynamodb-table.name
  description = "The name of the DynamoDB table"
}