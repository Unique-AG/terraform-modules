output "diagnostic_setting" {
  description = "Details of the Activity Log diagnostic setting."
  value       = azurerm_monitor_diagnostic_setting.activity_log_export
}

output "id" {
  description = "The ID of the diagnostic setting."
  value       = azurerm_monitor_diagnostic_setting.activity_log_export.id
}

output "name" {
  description = "The name of the diagnostic setting."
  value       = azurerm_monitor_diagnostic_setting.activity_log_export.name
}
