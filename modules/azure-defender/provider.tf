terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2"
    }
  }
}
