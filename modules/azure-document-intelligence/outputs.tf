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