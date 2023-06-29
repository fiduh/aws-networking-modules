variable "s3_bucket_name" {
  description = "Unique name of the s3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "tag_name" {
  description = "Tag Labels"
  type        = string
}