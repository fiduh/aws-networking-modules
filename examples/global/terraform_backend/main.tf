
module "s3_backend" {
  source = "../../../modules/s3"
  s3_bucket_name = "brains_terraform_backend"
  environment = "example"
  tag_name = "terraform"
}

module "dynamodb_lock" {
  source = "../../../modules/dynamodb"
  dynamodb_table_name = "dynamodb_lock"
}