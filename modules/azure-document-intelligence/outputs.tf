output "primary_access_keys" {
  description = "The primary access key of the Cognitive Services Account"
  value       = { for aca in azurerm_cognitive_account.aca : aca.name => aca.primary_access_key }
  sensitive   = true
}
output "azure_document_intelligence_endpoints" {
  value     = jsonencode(local.azure_document_intelligence_endpoints)
  sensitive = true
}
output "azure_document_intelligence_endpoint_definitions" {
  value     = jsonencode(local.azure_document_intelligence_endpoint_definitions)
  sensitive = true
}
output "endpoint_definitions_secret_name" {
  value = var.endpoint_definitions_secret_name
}
output "endpoints_secret_name" {
  value = var.endpoints_secret_name
}
output "keys_secret_names" {
    value = [for k, v in azurerm_key_vault_secret.key : v.name]
}