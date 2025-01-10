locals {
  create_vault_secrets = var.key_vault_id != null
}

resource "azurerm_key_vault_secret" "key" {
  for_each     = var.key_vault_id != null ? azurerm_cognitive_account.aca : []
  name         = "${each.key}${var.primary_access_key_secret_name_suffix}"
  value        = each.value.primary_access_key
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "azure_document_intelligence_endpoints" {
  count        = var.key_vault_id != null ? 1 : 0
  name         = var.endpoints_secret_name
  value        = jsonencode(local.azure_document_intelligence_endpoints)
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "azure_document_intelligence_endpoint_definitions" {
  count        = local.create_vault_secrets ? 1 : 0
  name         = var.endpoint_definitions_secret_name
  value        = jsonencode(local.azure_document_intelligence_endpoint_definitions)
  key_vault_id = var.key_vault_id
}