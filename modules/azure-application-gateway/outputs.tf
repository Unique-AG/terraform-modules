output "appgw_id" {
  description = "The ID of the Application Gateway"
  value       = azurerm_application_gateway.appgw.id
}

output "appgw_ip_address" {
  description = "The IP address of the Application Gateway"
  value       = var.public_ip_enabled ? try(azurerm_public_ip.appgw[0].ip_address, null) : var.private_ip # FIXME: if var.public_ip_address_id is specified, it will return null. It has been always broken
}
