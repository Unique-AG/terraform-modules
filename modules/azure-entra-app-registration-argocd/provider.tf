
terraform {
  # provider-defined functions (provider::time::rfc3339_parse)
  required_version = ">= 1.8"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.13"
    }
  }
}
