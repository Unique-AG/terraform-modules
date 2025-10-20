output "storage_account_1_id" {
  description = "ID of the first storage account"
  value       = module.storage_account_with_backup_1.storage_account_id
}

output "storage_account_1_backup_vault_name" {
  description = "Name of the backup vault for the first storage account (with unique suffix)"
  value       = module.storage_account_with_backup_1.backup_vault_name
}

output "storage_account_1_backup_vault_id" {
  description = "ID of the backup vault for the first storage account"
  value       = module.storage_account_with_backup_1.backup_vault_id
}

output "storage_account_2_id" {
  description = "ID of the second storage account"
  value       = module.storage_account_with_backup_2.storage_account_id
}

output "storage_account_2_backup_vault_name" {
  description = "Name of the backup vault for the second storage account (with unique suffix)"
  value       = module.storage_account_with_backup_2.backup_vault_name
}

output "storage_account_2_backup_vault_id" {
  description = "ID of the backup vault for the second storage account"
  value       = module.storage_account_with_backup_2.backup_vault_id
}

output "storage_account_3_id" {
  description = "ID of the third storage account"
  value       = module.storage_account_with_backup_3.storage_account_id
}

output "storage_account_3_backup_vault_name" {
  description = "Name of the backup vault for the third storage account (with unique suffix)"
  value       = module.storage_account_with_backup_3.backup_vault_name
}

output "storage_account_3_backup_vault_id" {
  description = "ID of the backup vault for the third storage account"
  value       = module.storage_account_with_backup_3.backup_vault_id
}

output "resource_group_name" {
  description = "Name of the resource group containing all resources"
  value       = azurerm_resource_group.example.name
}

output "unique_backup_vault_names" {
  description = "List of all unique backup vault names created"
  value = [
    module.storage_account_with_backup_1.backup_vault_name,
    module.storage_account_with_backup_2.backup_vault_name,
    module.storage_account_with_backup_3.backup_vault_name,
  ]
}

