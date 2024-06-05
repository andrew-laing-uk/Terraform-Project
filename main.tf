terraform {
  backend "s3" {
    bucket = "am-terraform-project-bucket"
    key    = "terraform.tfstate"
    region = "eu-west-2"
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
# Configure the ECR ressource
resource "aws_ecr_repository" "app_repo" {
  name                 = "task-listing-app"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}