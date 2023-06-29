output "s3_bucket_arn" {
  value       = module.s3_backend.s3_bucket_arn
  description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
  value       = module.dynamodb_lock.dynamodb_table_name
  description = "The name of the DynamoDB table"
}