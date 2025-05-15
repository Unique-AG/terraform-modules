resource "azurerm_key_vault_secret" "key" {
  count           = length(var.accounts)
  name            = "${keys(var.accounts)[count.index]}${var.primary_access_key_secret_name_suffix}"
  value           = azurerm_cognitive_account.aca[keys(var.accounts)[count.index]].primary_access_key
  key_vault_id    = var.key_vault_id
  expiration_date = "2099-12-31T23:59:59Z"
  content_type    = "text/plain"
}

resource "azurerm_key_vault_secret" "azure_speech_service_endpoints" {
  name            = var.endpoints_secret_name
  value           = jsonencode(local.azure_speech_service_endpoints)
  key_vault_id    = var.key_vault_id
  expiration_date = "2099-12-31T23:59:59Z"
  content_type    = "application/json"
}

resource "azurerm_key_vault_secret" "azure_speech_service_endpoint_definitions" {
  name            = var.endpoint_definitions_secret_name
  value           = jsonencode(local.azure_speech_service_endpoint_definitions)
  key_vault_id    = var.key_vault_id
  expiration_date = "2099-12-31T23:59:59Z"
  content_type    = "application/json"
}

resource "azurerm_key_vault_secret" "resource_id" {
  count           = length(var.accounts)
  name            = "${keys(var.accounts)[count.index]}${var.resource_id_secret_name_suffix}"
  value           = azurerm_cognitive_account.aca[keys(var.accounts)[count.index]].id
  key_vault_id    = var.key_vault_id
  expiration_date = "2099-12-31T23:59:59Z"
  content_type    = "text/plain"
}

resource "azurerm_key_vault_secret" "fqdn" {
  count = length(var.accounts)
  name  = "${keys(var.accounts)[count.index]}${var.fqdn_secret_name_suffix}"
  value = try(
    var.accounts[keys(var.accounts)[count.index]].custom_subdomain_name != null ?
    "${var.accounts[keys(var.accounts)[count.index]].custom_subdomain_name}.cognitiveservices.azure.com" :
    azurerm_cognitive_account.aca[keys(var.accounts)[count.index]].endpoint
  )
  key_vault_id    = var.key_vault_id
  expiration_date = "2099-12-31T23:59:59Z"
  content_type    = "text/plain"
}