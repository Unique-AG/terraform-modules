locals {
  create_vault_secrets = var.key_vault_output_settings != null && var.key_vault_output_settings.key_vault_output_enabled
}

resource "azurerm_key_vault_secret" "key" {
  for_each     = azurerm_cognitive_account.aca
  name         = "${each.key}${var.key_vault_output_settings.primary_access_key_secret_name_suffix}"
  value        = each.value.primary_access_key
  key_vault_id = var.key_vault_output_settings.key_vault_id
}

resource "azurerm_key_vault_secret" "azure_document_intelligence_endpoints" {
  name         = var.key_vault_output_settings.endpoints_secret_name
  value        = jsonencode(local.azure_document_intelligence_endpoints)
  key_vault_id = var.key_vault_output_settings.key_vault_id
}

resource "azurerm_key_vault_secret" "azure_document_intelligence_endpoint_definitions" {
  name         = var.key_vault_output_settings.endpoint_definitions_secret_name
  value        = jsonencode(local.azure_document_intelligence_endpoint_definitions)
  key_vault_id = var.key_vault_output_settings.key_vault_id
}