locals {
  create_vault_secrets = var.key_vault_id != null
}

resource "azurerm_key_vault_secret" "primary_access_keys" {
  for_each     = local.create_vault_secrets ? azurerm_cognitive_account.aca : {}
  name         = "${each.key}${var.primary_access_key_secret_name_suffix}"
  value        = each.value.primary_access_key
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "cognitive_account_endpoints" {
  count        = local.create_vault_secrets ? 1 : 0
  name         = var.endpoints_secret_name
  value        = { for aca in azurerm_cognitive_account.aca : aca.name => aca.endpoint }
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "model_version_endpoints" {
  count        = local.create_vault_secrets ? 1 : 0
  name         = var.endpoint_definitions_secret_name
  value        = jsonencode(local.model_version_endpoints)
  key_vault_id = var.key_vault_id
}
