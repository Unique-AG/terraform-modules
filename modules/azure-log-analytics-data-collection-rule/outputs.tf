output "dcr_id" {
  description = "Resource ID of the Data Collection Rule."
  value       = azurerm_monitor_data_collection_rule.this.id
}

output "dcr_name" {
  description = "Name of the Data Collection Rule."
  value       = azurerm_monitor_data_collection_rule.this.name
}

output "data_flow_tables" {
  description = "Log Analytics table names configured with ingestion-time transformations."
  value       = keys(local.data_flow_transformations)
}
