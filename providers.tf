terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-terraform-state-dev"
    storage_account_name = "stult8unwm3w"
    container_name       = "tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = "d5453260-ba13-475a-b686-0104a9566180"
}
