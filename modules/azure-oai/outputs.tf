output "cognitive_account_endpoints" {
  description = "The endpoints used to connect to the Cognitive Service Account."
  value       = values(azurerm_cognitive_account.aca)[*].endpoint
  sensitive   = true
}
output "primary_access_keys" {
  description = " A primary access keys which can be used to connect to the Cognitive Service Accounts."
  value       = values(azurerm_cognitive_account.aca)[*].primary_access_key
  sensitive   = true
}

output "model_version_endpoints" {
  description = "Map of endpoints where 'model_name-model_version is the key and endpoint is the value'"
  value       = jsonencode(local.model_version_endpoints)
  sensitive   = true
}