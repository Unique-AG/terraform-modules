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

resource "azurerm_user_assigned_identity" "storage_account_keyvault_key_reader_audit_logs" {
  name                = "uami-storage-account-keyvault-key-reader-audit-logs"
  location            = "switzerlandnorth"
  resource_group_name = "my-resource-group"
}

data "azurerm_role_definition" "kv_crypto_service_encryption_user" {
  name = "Key Vault Crypto Service Encryption User"
}

resource "azurerm_role_assignment" "kv_sens_storage_account_audit_logs_key_service_user" {
  scope              = azurerm_key_vault.sensitive.id
  role_definition_id = data.azurerm_role_definition.kv_crypto_service_encryption_user.id
  principal_id       = azurerm_user_assigned_identity.storage_account_keyvault_key_reader_audit_logs.principal_id
}

module "sa" {
  source              = "../.."
  name                = "my-storage-account"
  resource_group_name = "my-resource-group"
  location            = "switzerlandnorth"
  tags = {
    environment = "example"
  }

  identity_ids = [
    azurerm_user_assigned_identity.storage_account_keyvault_key_reader_audit_logs.id
  ]

  customer_managed_key = {
    key_vault_uri = azurerm_key_vault.sensitive.vault_uri
    key_name      = azurerm_key_vault_key.auditlogs_key.name
  }

  depends_on = [azurerm_role_assignment.kv_sens_storage_account_audit_logs_key_service_user, azurerm_key_vault_key.auditlogs_key]

  containers = {
    service-one = {
      access_type = "private"
    }
  }

  storage_management_policy_default = {
    enabled                                  = true
    deleted_retain_days                      = 7
    restorable_days                          = 6
    container_deleted_retain_days            = 7
    blob_to_cool_after_last_modified_days    = 1
    blob_to_cold_after_last_modified_days    = 2
    blob_to_archive_after_last_modified_days = 3
    blob_to_deleted_after_last_modified_days = 1825 # 5 years
  }

}
