output "appgw_id" {
  description = "The ID of the Application Gateway"
  value       = azurerm_application_gateway.appgw.id
}

output "appgw_ip_address" {
  description = "The IP address of the HTTP listener of the Application Gateway"
  value       = var.http_listener_private_ip_configuration_enabled ? var.private_ip : try(data.azurerm_public_ip.appgw[0].ip_address, null)
}
