generate "backend" {
  path = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
    terraform {
      backend "azurerm" {
        resource_group_name = "rg-tfstate-lowers-001"
        storage_account_name = "stgtfstatelowers001"
        container_name  = "tf-state"
        key = "${path_relative_to_include()}/terraform.tfstate"
      }
    } 
  EOF
}
