terraform {
  required_version = ">= 1.9.7"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.115.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

provider "null" {}


module "rg" {
  source = "../"
  resource_groups = {
    rg1 = {
      name     = "rg1"
      location = "eastus"
      tags = {
        environment = "dev"
      }
    }
    rg2 = {
      name     = "rg2"
      location = "westus"
      tags = {
        environment = "dev"
      }
    }
  }
}
