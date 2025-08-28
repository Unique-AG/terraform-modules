output "manual_secrets_created" {
  description = "List of names of secrets created in the core key vault."
  sensitive   = false
  value = [
    for key, value in azurerm_key_vault_secret.manual_secret : value.id
    if lookup(local.manual_secrets[key], "create", true)
  ]
}

output "sops_age_keys_custom_assistant" {
  description = "The public keys of the SOPS age keys for custom assistants. The keys are public and have a secret, private, asymmetric sibling. Learn more at https://github.com/getsops/sops. These keys must and should be provided plain text to the Developers or put into their repository."
  sensitive   = false
  value = {
    key_1 = var.secrets_to_create.sops_age_key_custom_assistant_1.create ? age_secret_key.sops_age_key_custom_assistant_1.public_key : null
    key_2 = var.secrets_to_create.sops_age_key_custom_assistant_2.create ? age_secret_key.sops_age_key_custom_assistant_2.public_key : null
  }
}