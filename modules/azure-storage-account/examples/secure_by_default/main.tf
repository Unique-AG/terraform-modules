terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

resource "azurerm_key_vault" "sensitive" {
  name                = "kvsens"
  location            = "switzerlandnorth"
  resource_group_name = "my-resource-group"
  tenant_id           = "58455a0c-c831-4f5a-b460-07156e44f4c2"

  sku_name = "premium" # needed for HSM keys
}

resource "azurerm_key_vault_key" "auditlogs_key" {
  name         = "auditlogs-key"
  key_vault_id = azurerm_key_vault.sensitive.id
  key_type     = "RSA-HSM"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

resource "azurerm_user_assigned_identity" "storage_account_keyvault_key_reader" {
  name                = "uami-storage-account-keyvault-key-reader-audit-logs"
  location            = "switzerlandnorth"
  resource_group_name = "my-resource-group"
}

data "azurerm_role_definition" "kv_crypto_service_encryption_user" {
  name = "Key Vault Crypto Service Encryption User"
}

resource "azurerm_role_assignment" "kv_sens_storage_account_key_service_user" {
  scope              = azurerm_key_vault.sensitive.id
  role_definition_id = data.azurerm_role_definition.kv_crypto_service_encryption_user.id
  principal_id       = azurerm_user_assigned_identity.storage_account_keyvault_key_reader.principal_id
}

module "sa" {
  source     = "../.."
  depends_on = [azurerm_role_assignment.kv_sens_storage_account_key_service_user, azurerm_key_vault_key.auditlogs_key]

  name                = "stingestio"
  access_tier         = "Hot"
  location            = "switzerlandnorth"
  resource_group_name = "my-resource-group"

  identity_ids = [
    azurerm_user_assigned_identity.storage_account_keyvault_key_reader.id
  ]

  backup_vault = {
    name = "bv-stingestion"
  }
  backup_instance = {
    name = "bi-stingestion"
  }
  backup_policy = {
    name = "bp-stingestion"
  }

  customer_managed_key = {
    key_name                  = azurerm_key_vault_key.auditlogs_key.name
    key_vault_id              = azurerm_key_vault.sensitive.id
    user_assigned_identity_id = azurerm_user_assigned_identity.storage_account_keyvault_key_reader.id
  }

  storage_management_policy_default = {
    blob_to_cool_after_last_modified_days    = 14
    blob_to_cold_after_last_modified_days    = 30
    blob_to_archive_after_last_modified_days = 5 * 365
    blob_to_deleted_after_last_modified_days = 5 * 365
  }

  network_rules = {
    ip_rules = ["12.34.56.78/21"]
    private_link_accesses = [{
      endpoint_resource_id = "/sub/uuid/scanner"
      endpoint_tenant_id   = "58455a0c-c831-4f5a-b460-07156e44f4c2"
    }]
    virtual_network_subnet_ids = ["/subnet/id"]
  }
}
