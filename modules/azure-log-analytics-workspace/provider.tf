terraform {
  required_version = ">= 1.5"
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.4"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.15"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.13"
    }
  }
}
