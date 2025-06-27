terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
data "azurerm_client_config" "current" {}

# Generate random names for resources
resource "random_string" "random" {
  length  = 12
  special = false
  upper   = false
}

resource "azurerm_resource_group" "example" {
  name     = "rg-${random_string.random.result}"
  location = "East US"
}

resource "azurerm_key_vault" "example" {
  name                       = "kv-${random_string.random.result}"
  sku_name                   = "premium"
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  enable_rbac_authorization  = true
  purge_protection_enabled   = true
  soft_delete_retention_days = 7
}

resource "azurerm_user_assigned_identity" "example" {
  name                = "id-${random_string.random.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Only role assignment needed for customer-managed key functionality
resource "azurerm_role_assignment" "key_vault_crypto_operator" {
  scope                = azurerm_key_vault.example.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_user_assigned_identity.example.principal_id
}

module "storage_account_with_simple_backup" {
  source = "../../"

  name                = "st${random_string.random.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  identity_ids        = [azurerm_user_assigned_identity.example.id]
  self_cmk = {
    key_vault_id              = azurerm_key_vault.example.id
    key_name                  = "self-cmk"
    user_assigned_identity_id = azurerm_user_assigned_identity.example.id
  }

} 