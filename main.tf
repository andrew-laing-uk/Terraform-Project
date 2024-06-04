terraform {
  backend "s3" {
    bucket = var.bucket_name
    key    = "terraform.tfstate"
    region = var.region
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}
