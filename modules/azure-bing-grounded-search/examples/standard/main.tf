terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

resource "azurerm_resource_group" "example" {
  name     = "example-resource-group"
  location = "switzerlandnorth"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/22"]
}

resource "azurerm_subnet" "aks_pods" {
  name                 = "example-aks-pods-subnet"
  virtual_network_name = azurerm_virtual_network.example.name
  resource_group_name  = azurerm_resource_group.example.name
  address_prefixes     = ["10.0.0.0/24"]

  service_endpoints = ["Microsoft.CognitiveServices"]
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "example" {
  name                = "example-kv"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id
}

module "bing_grounded_search" {
  source = "../.."

  resource_group_name = azurerm_resource_group.example.name
  tags                = { Environment = "example" }
  key_vault_id        = azurerm_key_vault.example.id

  foundry_account = {
    name                               = "fdry-example-001"
    custom_subdomain_name              = "fdry-example-001"
    location                           = azurerm_resource_group.example.location
    virtual_network_subnet_ids_allowed = [azurerm_subnet.aks_pods.id]
  }

  foundry_projects = {
    "uat-agents-001" = {
      description  = "Project to setup Grounded Search for Bing."
      display_name = "UAT Project 001 - Bing Grounded Search"
    }
  }

  deployment = {
    name          = "gpt-4o-deployment"
    model_name    = "gpt-4o"
    model_version = "2024-11-20"
    sku_name      = "GlobalStandard"
    sku_capacity  = 5000
  }

  bing_account = {
    name              = "bgs-example-001"
    resource_group_id = azurerm_resource_group.example.id
  }
}
