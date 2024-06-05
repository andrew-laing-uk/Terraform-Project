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
  name                 = "am-task-listing-app"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_elastic_beanstalk_application" "am_eb_app" {
  name        = "am-task-listing-app"
  description = "Task listing app"
}

resource "aws_elastic_beanstalk_environment" "am_eb_app_environment" {
  name        = "am-task-listing-app-environment"
  application = aws_elastic_beanstalk_application.am_eb_app.name

  # This page lists the supported platforms
  # we can use for this argument:
  # https://docs.aws.amazon.com/elasticbeanstalk/latest/platforms/platforms-supported.html#platforms-supported.docker
  solution_stack_name = "64bit Amazon Linux 2023 v4.3.2 running Docker"

}