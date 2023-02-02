#This is file which has terraform modules, providers, versions etc details.

terraform {
  required_version = "~> 1.3.3"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # version = "~> 3.0"
      version = "~> 4.51.0"
    }
  }

  # this bucket needs to create manually, with versioning enabled
  backend "s3" {
    bucket = "rearc-quest-tasks-trfm-bckend-statefile"
    region = "us-east-1"
    key    = "statefile/terraform.tstate"
  }
}

provider "aws" {
  profile = "default"
  region  = var.rearc-quest-tasks-trfm-aws_region
}