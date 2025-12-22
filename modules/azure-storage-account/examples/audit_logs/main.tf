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
  source     = "../.."
  depends_on = [azurerm_role_assignment.kv_sens_storage_account_audit_logs_key_service_user, azurerm_key_vault_key.auditlogs_key]

  name                     = "stauditlogs"
  access_tier              = "Hot"
  account_replication_type = "LRS"
  location                 = "switzerlandnorth"
  resource_group_name      = "my-resource-group"

  is_nfs_mountable = true # so it can be attached to pods

  identity_ids = [
    azurerm_user_assigned_identity.storage_account_keyvault_key_reader_audit_logs.id
  ]

  customer_managed_key = {
    key_name                  = azurerm_key_vault_key.auditlogs_key.name
    key_vault_id              = azurerm_key_vault.sensitive.id
    user_assigned_identity_id = azurerm_user_assigned_identity.storage_account_keyvault_key_reader_audit_logs.id
  }

  containers = {
    for container in [
      "configuration-backend",
      "node-app-repository",
      "node-chat",
      "node-ingestion-worker-chat",
      "node-ingestion-worker",
      "node-ingestion",
      "node-scope-management",
      ] : container => {
      access_type = "private"
    }
  }

  backup_vault = null # backup vaults don't support NFS/HNS

  data_protection_settings = {
    change_feed_retention_days = -1    # cant be active when versioning is disabled
    point_in_time_restore_days = -1    # cant be active when versioning is disabled
    versioning_enabled         = false # NFS cant use versioning
  }

  storage_management_policy_default = {
    blob_to_cool_after_last_modified_days    = 1
    blob_to_cold_after_last_modified_days    = 7
    blob_to_archive_after_last_modified_days = 90
    blob_to_deleted_after_last_modified_days = 1825 # 5 years
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
