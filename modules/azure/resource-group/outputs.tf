output "resource_group_names" {
  description = "List of resource group names created by this configuration"
  value       = [for rg in azurerm_resource_group.this : rg.name]
}

output "resource_group_locations" {
  description = "Map of resource group locations by name"
  value       = { for rg in azurerm_resource_group.this : rg.name => rg.location }
}

output "resource_group_ids" {
  description = "Map of resource group tags by name"
  value       = { for rg in azurerm_resource_group.this : rg.name => rg.id }
}
