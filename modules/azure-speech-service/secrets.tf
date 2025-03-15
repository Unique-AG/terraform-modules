resource "azurerm_key_vault_secret" "key" {
  count        = length(var.accounts)
  name         = "${keys(var.accounts)[count.index]}${var.primary_access_key_secret_name_suffix}"
  value        = azurerm_cognitive_account.aca[keys(var.accounts)[count.index]].primary_access_key
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "azure_speech_service_endpoints" {
  name         = var.endpoints_secret_name
  value        = jsonencode(local.azure_speech_service_endpoints)
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "azure_speech_service_endpoint_definitions" {
  name         = var.endpoint_definitions_secret_name
  value        = jsonencode(local.azure_speech_service_endpoint_definitions)
  key_vault_id = var.key_vault_id
}