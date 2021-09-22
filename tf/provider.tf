terraform {
  required_providers {
      azurerm = {
          version = "~> 2"
      }
  }
}

provider "azurerm" {
  features {}
}