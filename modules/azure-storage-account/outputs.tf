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

output "backup_vault_id" {
  description = "The ID of the backup vault"
  value       = var.backup_vault != null ? azurerm_data_protection_backup_vault.backup_vault[0].id : null
}

output "backup_vault_name" {
  description = "The name of the backup vault"
  value       = var.backup_vault != null ? azurerm_data_protection_backup_vault.backup_vault[0].name : null
}

output "backup_policy_id" {
  description = "The ID of the backup policy"
  value       = var.backup_vault != null ? azurerm_data_protection_backup_policy_blob_storage.backup_policy[0].id : null
}

output "backup_instance_id" {
  description = "The ID of the backup instance"
  value       = var.backup_vault != null ? azurerm_data_protection_backup_instance_blob_storage.backup_instance[0].id : null
}
