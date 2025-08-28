terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3"
    }
    age = {
      source  = "clementblaise/age"
      version = "~> 0.1.1"
    }
  }
}
