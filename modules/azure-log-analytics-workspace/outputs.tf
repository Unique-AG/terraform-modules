output "data_flow_tables" {
  description = "Log Analytics table names configured with ingestion-time transformations."
  value       = local.dcr_enabled ? keys(local.dcr_transformations) : []
}

output "dcr_id" {
  description = "Resource ID of the workspace-transform DCR, or null when data_collection_rule is disabled."
  value       = local.dcr_enabled ? azurerm_monitor_data_collection_rule.this[0].id : null
}

output "dcr_name" {
  description = "Name of the workspace-transform DCR, or null when data_collection_rule is disabled."
  value       = local.dcr_enabled ? azurerm_monitor_data_collection_rule.this[0].name : null
}

output "workspace_id" {
  description = "Resource ID of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.this.id
}

output "workspace_location" {
  description = "Azure region of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.this.location
}

output "workspace_name" {
  description = "Name of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.this.name
}

output "workspace_resource_group_name" {
  description = "Resource group name of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.this.resource_group_name
}
