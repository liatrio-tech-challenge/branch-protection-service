terraform {
  backend "azurerm" {
    storage_account_name = "githubtechchalbackend"
    resource_group_name  = "github-tech-chal-backend"
    container_name       = "tfstate"
    key                  = "infra/terraform.tfstate"
  }
}
