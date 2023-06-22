terraform {
    backend "s3" {
    bucket = "brains-backend"
    key = "examples/global/terraform_backend/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "dynamodb_lock"
    encrypt = true
  }
}
module "s3_backend" {
  source = "../../../modules/s3"
  s3_bucket_name = "brains-backend"
  environment = "example"
  tag_name = "terraform"
}

module "dynamodb_lock" {
  source = "../../../modules/dynamodb"
  dynamodb_table_name = "dynamodb_lock"
}