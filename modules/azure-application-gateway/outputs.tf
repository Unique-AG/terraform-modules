output "appgw_id" {
  description = "The ID of the Application Gateway"
  value       = azurerm_application_gateway.appgw.id
}

output "appgw_name" {
  description = "The name of the Application Gateway"
  value       = azurerm_application_gateway.appgw.name
}

output "appgw_ip_address" {
  description = "The public IP address of the Application Gateway"
  value       = try(azurerm_public_ip.appgw[0].ip_address, null)
}
