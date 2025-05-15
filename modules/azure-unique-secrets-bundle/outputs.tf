output "manual_secrets_created" {
  description = "List of names of secrets created in the core key vault."
  sensitive   = false
  value = [
    for key, value in azurerm_key_vault_secret.manual_secret : value.id
    if lookup(local.manual_secrets[key], "create", true)
  ]
}
