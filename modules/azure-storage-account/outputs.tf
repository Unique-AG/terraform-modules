output "storage_account_connection_strings" {
  description = "Connection strings for the storage account, provided for backward compatibility reasons. It is recommended to use Workload or Managed Identity authentication wherever possible."
  sensitive   = true
  value = {
    primary   = azurerm_storage_account.storage_account.primary_connection_string
    secondary = azurerm_storage_account.storage_account.secondary_connection_string
  }
}