variable "region" {
  description = "AWS region of the s3 bucket"
  type        = string
  default     = "eu-west-2"
}
variable "bucket_name" {
  description = "Name of the s3 bucket"
  type        = string
  default     = "am-terraform-project-bucket"
}
