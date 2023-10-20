terraform {
  required_version = ">= 1.5.3, < 2.0.0"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11.0"
    }
  }

  backend "s3" {
    bucket = "conquer-project-tf-state"
    key    = "tf-states/infrastructure/ephemeral-resources/k8s-deployments/terraform.tfstate"
    region = "us-east-1"
  }

}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
