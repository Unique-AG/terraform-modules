locals {
  key_placeholder      = "<API_KEY_NOT_AVAILABLE>"
  create_vault_secrets = var.key_vault_id != null
  # Filtered  cognitive accounts to include only those with a local auth enabled
  aca_with_local_auth = {
    for k, v in var.cognitive_accounts : k => v
    if v.local_auth_enabled
  }
}

resource "azurerm_key_vault_secret" "key" {
  for_each = local.create_vault_secrets ? local.aca_with_local_auth : {}

  content_type    = "text/plain"
  expiration_date = var.primary_access_key_secret.expiration_date
  key_vault_id    = var.key_vault_id
  name            = "${each.key}${var.primary_access_key_secret.name_suffix}"
  tags            = merge(var.tags, var.primary_access_key_secret.extra_tags)
  value           = azurerm_cognitive_account.aca[each.value.name].primary_access_key != null ? azurerm_cognitive_account.aca[each.value.name].primary_access_key : local.key_placeholder
}

# Store the endpoint for each cognitive account in Key Vault
resource "azurerm_key_vault_secret" "endpoint" {
  for_each = local.create_vault_secrets ? azurerm_cognitive_account.aca : {}

  content_type    = "text/plain"
  expiration_date = var.endpoint_secret.expiration_date
  key_vault_id    = var.key_vault_id
  name            = "${each.key}${var.endpoint_secret.name_suffix}"
  tags            = merge(var.tags, var.endpoint_secret.extra_tags)
  value           = each.value.endpoint
}

resource "azurerm_key_vault_secret" "model_version_endpoints" {
  count = local.create_vault_secrets ? 1 : 0

  content_type    = "application/json"
  key_vault_id    = var.key_vault_id
  name            = var.endpoint_definitions_secret.name
  tags            = merge(var.tags, var.endpoint_definitions_secret.extra_tags)
  value           = jsonencode(local.model_version_endpoints)
  expiration_date = var.endpoint_definitions_secret.expiration_date
}
