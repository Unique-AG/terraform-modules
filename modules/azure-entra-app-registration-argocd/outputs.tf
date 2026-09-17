output "client_id" {
  description = "The client ID of the Azure AD application."
  value       = azuread_application.this.client_id
}

output "client_secret" {
  description = "The client secret of the Azure AD application."
  sensitive   = true
  value       = var.client_secret_generation_config.enabled && var.client_secret_generation_config.output_enabled ? azuread_application_password.aad_app_password[0].value : null
}

output "client_secret_end_date" {
  description = "RFC3339 expiry of the Terraform-managed Entra client secret."
  value       = var.client_secret_generation_config.enabled ? azuread_application_password.aad_app_password[0].end_date : null
}
