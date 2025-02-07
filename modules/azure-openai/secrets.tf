locals {
  create_vault_secrets      = var.key_vault_id != null
  create_vault_secrets_sens = var.sens_key_vault_id != null
  # Filtered  cognitive accounts to include only those with a local auth enabled
  aca_with_local_auth = {
    for k, v in var.cognitive_accounts : k => v
    if v.local_auth_enabled
  }
}

resource "azurerm_key_vault_secret" "key" {
  for_each     = local.create_vault_secrets_sens ? local.aca_with_local_auth : {}
  name         = "${each.key}${var.primary_access_key_secret_name_suffix}"
  value        = azurerm_cognitive_account.aca[each.value.name].primary_access_key
  key_vault_id = var.sens_key_vault_id
}

# Store the endpoint for each cognitive account in Key Vault
resource "azurerm_key_vault_secret" "endpoint" {
  for_each     = local.create_vault_secrets ? azurerm_cognitive_account.aca : {}
  name         = "${each.key}${var.endpoint_secret_name_suffix}"
  value        = each.value.endpoint
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "model_version_endpoints" {
  count        = local.create_vault_secrets ? 1 : 0
  name         = var.endpoint_definitions_secret_name
  value        = jsonencode(local.model_version_endpoints)
  key_vault_id = var.key_vault_id
}
