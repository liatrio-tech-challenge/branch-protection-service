provider "azurerm" {
  features {}
}

provider "github" {
  owner = "liatrio-tech-challenge"
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.91"
    }
    github = {
      source  = "integrations/github"
      version = "~>4.19.1"
    }
  }
}