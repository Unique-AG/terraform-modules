output "storage_account_connection_strings" {
  description = "Connection strings for the storage account, provided for backward compatibility reasons. It is recommended to use Workload or Managed Identity authentication wherever possible"
  sensitive   = true
  value = {
    primary   = azurerm_storage_account.storage_account.primary_connection_string
    secondary = azurerm_storage_account.storage_account.secondary_connection_string
  }
}

output "storage_account_id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.storage_account.id
}
output "storage_account_name" {
  description = "The name of the storage account. Recommended only to be used for data sourcing as the Azure RM provider recommends using the ID instead for managing state."
  value       = azurerm_storage_account.storage_account.name
}
