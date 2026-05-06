
terraform {
  required_version = ">= 1.12"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.39"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.4"
    }
  }
}
