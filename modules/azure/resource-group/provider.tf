provider "azurerm" {}
terraform {
  required_version = ">= 1.9.7"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.115.0"
    }
  }
}