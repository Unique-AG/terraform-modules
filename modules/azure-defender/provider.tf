terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.15"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "2.2.0"
    }
  }
}
