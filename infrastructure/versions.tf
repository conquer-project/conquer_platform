terraform {
  required_version = ">= 1.5.3, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.12.0"
    }
  }

  backend "s3" {
    bucket = "conquer-project-tf-state"
    key    = "tf-states/infrastructure/terraform.tfstate"
    region = "us-east-1"
  }

}

provider "aws" {
  region = "eu-north-1"
  default_tags {
    tags = {
      project = local.project
      owners  = "the-devops-guys"
    }
  }
}
