terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "my-resource-group"
  location = "switzerlandnorth"
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  private_endpoint_network_policies = "Disabled"
}

# Key Vault with RBAC
resource "azurerm_key_vault" "kv" {
  name                      = "kv-${random_string.unique.result}"
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  sku_name                  = "standard"
  purge_protection_enabled  = false
  enable_rbac_authorization = true
}

# RBAC role assignment for Key Vault Administrator
resource "azurerm_role_assignment" "kv_admin" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "law" {
  name                = "workspace1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Get current Azure context
data "azurerm_client_config" "current" {}

# Create a user-assigned managed identity (optional)
resource "azurerm_user_assigned_identity" "example" {
  name                = "speech-service-identity"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

# Update the module to use the created resources
module "speech_service" {
  source              = "../.."
  speech_service_name = "my-speech-service"
  key_vault_id        = azurerm_key_vault.kv.id
  accounts = {
    "switzerlandnorth-speech" = {
      location              = azurerm_resource_group.rg.location
      account_kind          = "SpeechServices"
      account_sku_name      = "S0"
      custom_subdomain_name = "my-speech-service-switzerlandnorth"

      # Optional identity configuration
      identity = {
        type         = "UserAssigned"
        identity_ids = [azurerm_user_assigned_identity.example.id]
      }

      private_endpoint = {
        subnet_id = azurerm_subnet.subnet.id
        vnet_id   = azurerm_virtual_network.vnet.id
      }

      diagnostic_settings = {
        log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
        enabled_log_categories     = ["Audit", "RequestResponse"]
        enabled_metrics            = ["AllMetrics"]
      }

      network_security_group = {
        security_rules = [
          {
            name                       = "AllowToSpeech"
            priority                   = 100
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_port_range          = "*"
            destination_port_range     = "443"
            source_address_prefix      = "*"
            destination_address_prefix = "*"
          }
        ]
      }

      workload_identity = {
        principal_id         = data.azurerm_client_config.current.object_id
        role_definition_name = "Cognitive Services User"
      }
    }
  }
  tags = {
    environment = "example"
  }
  resource_group_name = azurerm_resource_group.rg.name
}

# Add random string resource
resource "random_string" "unique" {
  length  = 8
  special = false
  upper   = false
} 