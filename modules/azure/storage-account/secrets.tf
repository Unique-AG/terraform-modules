resource "azurerm_key_vault_secret" "storage-account-connection-string-1" {
  name         = "storage-account-connection-string-1"
  value        = azurerm_storage_account.storage_account.primary_connection_string
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "storage-account-connection-string-2" {
  name         = "storage-account-connection-string-2"
  value        = azurerm_storage_account.storage_account.secondary_connection_string
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_key" "storage-account-byok" {
  name         = "storage-account-byok"
  key_vault_id = var.key_vault_id
  key_type     = "RSA-HSM"
  key_size     = var.customer_managed_key_size

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

resource "azurerm_storage_account_customer_managed_key" "storage_account_cmk" {
  storage_account_id = azurerm_storage_account.storage_account.id
  key_vault_id       = var.key_vault_id
  key_name           = azurerm_key_vault_key.storage-account-byok.name
  depends_on         = [azurerm_key_vault_key.storage-account-byok]
}