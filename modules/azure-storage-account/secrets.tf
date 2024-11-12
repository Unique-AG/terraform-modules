
# resource "azurerm_key_vault_key" "storage-account-byok" {
#   name         = "storage-account-byok"
#   key_vault_id = var.key_vault_id
#   key_type     = "RSA-HSM"
#   key_size     = var.customer_managed_key_size

#   key_opts = [
#     "decrypt",
#     "encrypt",
#     "sign",
#     "unwrapKey",
#     "verify",
#     "wrapKey",
#   ]
# }

# resource "azurerm_storage_account_customer_managed_key" "storage_account_cmk" {
#   storage_account_id = azurerm_storage_account.storage_account.id
#   key_vault_id       = var.key_vault_id
#   key_name           = azurerm_key_vault_key.storage-account-byok.name
#   depends_on         = [azurerm_key_vault_key.storage-account-byok]
# }

# resource "azurerm_role_assignment" "rbac_keyvault_managed_identity" {
#   # use this if customer_managed_key is SET but NO identity is passed
#   count =
#   for_each             = toset(["Key Vault Crypto User"])
#   scope                = azurerm_key_vault.this.id
#   role_definition_name = each.value
#   principal_id         = azurerm_storage_account.this.identity.0.principal_id
# }

# resource "azurerm_role_assignment" "rbac_keyvault_managed_identity" {
#   # use this if customer_managed_key is SET but BUT identity is passed
#   count =
#   for_each             = toset(["Key Vault Crypto User"])
#   scope                = azurerm_key_vault.this.id
#   role_definition_name = each.value
#   principal_id         = azurerm_storage_account.this.identity.0.principal_id
# }
