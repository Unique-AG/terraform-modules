# Random provider for unique names
provider "random" {}

# Random strings for resource names
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-storage-${random_string.suffix.result}"
  location = "switzerlandnorth"
  tags = {
    environment = "production"
    project     = "example"
    managed-by  = "terraform"
  }
}

# Virtual Network and Subnet
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-storage-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
  tags = {
    environment = "production"
    project     = "example"
    managed-by  = "terraform"
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "snet-storage-${random_string.suffix.result}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
}

# Key Vault
resource "azurerm_key_vault" "kv" {
  name                = "kv-storage-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # Enable both Purge Protection and Soft Delete
  purge_protection_enabled   = true
  soft_delete_retention_days = 7

  # Enable RBAC authorization
  enable_rbac_authorization = true

  tags = {
    environment = "production"
    project     = "example"
    managed-by  = "terraform"
  }
}

# Key Vault Key for Storage Account Encryption
resource "azurerm_key_vault_key" "storage_key" {
  name         = "key-storage-${random_string.suffix.result}"
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  tags = {
    environment = "production"
    project     = "example"
    managed-by  = "terraform"
  }
}

# RBAC Role Assignment for Storage Account Identity
resource "azurerm_role_assignment" "storage_identity_key_vault_crypto" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_user_assigned_identity.storage_identity.principal_id
}

# RBAC Role Assignment for Storage Account Identity to access Key Vault
resource "azurerm_role_assignment" "storage_identity_key_vault_access" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.storage_identity.principal_id
}

# RBAC Role Assignment for Storage Account Identity to manage storage account
resource "azurerm_role_assignment" "storage_identity_storage_account" {
  scope                = module.sa.storage_account_id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azurerm_user_assigned_identity.storage_identity.principal_id
}

# RBAC Role Assignment for Current User
resource "azurerm_role_assignment" "current_user_key_vault_admin" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Additional RBAC Role Assignment for Current User to manage secrets
resource "azurerm_role_assignment" "current_user_key_vault_secrets" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Additional RBAC Role Assignment for Current User to manage keys
resource "azurerm_role_assignment" "current_user_key_vault_crypto" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# User Assigned Managed Identity
resource "azurerm_user_assigned_identity" "storage_identity" {
  name                = "id-storage-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags = {
    environment = "production"
    project     = "example"
    managed-by  = "terraform"
  }
}

# Private DNS Zone
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
  tags = {
    environment = "production"
    project     = "example"
    managed-by  = "terraform"
  }
}

# Data source for current Azure client configuration
data "azurerm_client_config" "current" {}
