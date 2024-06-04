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

resource "aws_instance" "app_server" {
  ami           = "ami-0d26eb3972b7f8c96"
  instance_type = "t2.micro"
}
