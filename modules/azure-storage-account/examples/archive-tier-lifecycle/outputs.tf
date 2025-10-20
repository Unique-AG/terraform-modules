output "storage_account_lrs_id" {
  description = "The ID of the LRS storage account with Archive tier enabled"
  value       = module.storage_account_lrs_archive.storage_account_id
}

output "storage_account_lrs_name" {
  description = "The name of the LRS storage account with Archive tier enabled"
  value       = module.storage_account_lrs_archive.storage_account_name
}

output "storage_account_grs_id" {
  description = "The ID of the GRS storage account with Archive tier enabled"
  value       = module.storage_account_grs_archive.storage_account_id
}

output "storage_account_grs_name" {
  description = "The name of the GRS storage account with Archive tier enabled"
  value       = module.storage_account_grs_archive.storage_account_name
}

output "storage_account_zrs_id" {
  description = "The ID of the ZRS storage account without Archive tier"
  value       = module.storage_account_zrs_no_archive.storage_account_id
}

output "storage_account_zrs_name" {
  description = "The name of the ZRS storage account without Archive tier"
  value       = module.storage_account_zrs_no_archive.storage_account_name
}

output "resource_group_name" {
  description = "The name of the resource group containing all example resources"
  value       = azurerm_resource_group.example.name
}





