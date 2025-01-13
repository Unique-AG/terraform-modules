# Store the primary access key for each cognitive account in Key Vault
resource "azurerm_key_vault_secret" "key" {
  for_each     = azurerm_cognitive_account.aca
  name         = "${each.key}-key"
  value        = each.value.primary_access_key
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "azure_document_intelligence_endpoints" {
  name         = "azure-document-intelligence-endpoints"
  value        = jsonencode(local.azure_document_intelligence_endpoints)
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "azure_document_intelligence_endpoint_definitions" {
  name         = "azure-document-intelligence-endpoint-definitions"
  value        = jsonencode(local.azure_document_intelligence_endpoint_definitions)
  key_vault_id = var.key_vault_id
}
