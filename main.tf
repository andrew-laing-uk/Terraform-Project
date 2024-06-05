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

# Configure an IAM Role
resource "aws_iam_role" "am-role-elb" {
  name = "am-role-elb-name"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach policies to the IAM Role
resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier",
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker",
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])
  role       = aws_iam_role.am-role-elb.name
  policy_arn = each.value
}

# Configure IAM instance profile
resource "aws_iam_instance_profile" "am_eb_app_ec2_instance_profile" {
  name = "am_eb_app_ec2_instance_name"
  role = aws_iam_role.am-role-elb.name
}

# Configure Elastic Beanstalk Application
resource "aws_elastic_beanstalk_application" "am_eb_app" {
  name        = "am-task-listing-app"
  description = "Task listing app"
}

# Configure Elastic Beanstalk Application Environment
resource "aws_elastic_beanstalk_environment" "am_eb_app_environment" {
  name        = "am-task-listing-app-environment"
  application = aws_elastic_beanstalk_application.am_eb_app.name

  solution_stack_name = "64bit Amazon Linux 2023 v4.3.2 running Docker"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.am_eb_app_ec2_instance_profile.name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "am-terraform-keypair"
  }
}

# Configure the S3 Bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "am-docker-image-s3-bucket"

  tags = {
    Name = "MyS3Bucket"
  }
}