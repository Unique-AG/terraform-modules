output "appgw_id" {
  description = "The ID of the Application Gateway"
  value       = azurerm_application_gateway.appgw.id
}

output "appgw_ip_address" {
  description = "The public IP address of the Application Gateway"
  value       = azurerm_public_ip.appgw[0].ip_address
}
