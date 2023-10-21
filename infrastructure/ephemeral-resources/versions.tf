terraform {
  required_version = ">= 1.5.3, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.12.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11.0"
    }
  }

  backend "s3" {
    bucket = "conquer-project-tf-state"
    key    = "tf-states/infrastructure/ephemeral-resources/terraform.tfstate"
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

provider "helm" {
  # https://registry.terraform.io/providers/hashicorp/helm/latest/docs#exec-plugins
  kubernetes {
    host                   = aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.eks.name]
    }
  }
}
