output "foundry_account_endpoint" {
  description = "The endpoint of the AI Foundry cognitive account"
  value       = azurerm_cognitive_account.foundry_account.endpoint
}

output "foundry_account_id" {
  description = "The ID of the AI Foundry cognitive account"
  value       = azurerm_cognitive_account.foundry_account.id
}

output "secret_names" {
  description = "The composed Key Vault secret names created by this module"
  value = {
    project_endpoint = {
      for k, v in azurerm_key_vault_secret.project_endpoint : k => v.name
    }
    bing_connection_string = {
      for k, v in azurerm_key_vault_secret.bing_connection_string : k => v.name
    }
    bing_agent_model = azurerm_key_vault_secret.bing_agent_model.name
  }
}
