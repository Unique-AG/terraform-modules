resource "azurerm_key_vault_secret" "project_endpoint" {
  for_each = var.foundry_projects

  content_type    = "text/plain"
  expiration_date = var.secret_names.project_endpoint.expiration_date
  key_vault_id    = var.key_vault_id
  name            = "${var.secret_names.project_endpoint.name}-${each.key}"
  value           = "${trimsuffix(azurerm_cognitive_account.foundry_account.endpoint, "/")}/api/projects/${each.key}"
}

resource "azurerm_key_vault_secret" "bing_connection_string" {
  for_each = var.foundry_projects

  content_type    = "text/plain"
  expiration_date = var.secret_names.bing_connection_string.expiration_date
  key_vault_id    = var.key_vault_id
  name            = "${var.secret_names.bing_connection_string.name}-${each.key}"
  value           = azapi_resource.bing_search_connection[each.key].id
}

resource "azurerm_key_vault_secret" "bing_agent_model" {
  content_type    = "text/plain"
  expiration_date = var.secret_names.bing_agent_model.expiration_date
  key_vault_id    = var.key_vault_id
  name            = var.secret_names.bing_agent_model.name
  value           = var.deployment.name
}
