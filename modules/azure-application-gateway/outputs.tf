output "appgw_id" {
  description = "The ID of the Application Gateway"
  value       = azurerm_application_gateway.appgw.id
}

output "appgw_name" {
  description = "The name of the Application Gateway"
  value       = azurerm_application_gateway.appgw.name
}

output "private_frontend_ip_address" {
  description = "Private IP literal if configured with Static allocation; null otherwise. For Dynamic allocation, Azure assigns the IP and it is not exposed as a flat attribute on the resource — query via Azure CLI/data source after apply."
  value = try(
    var.private_frontend_ip_configuration.address_allocation == "Static"
    ? var.private_frontend_ip_configuration.private_ip_address
    : null,
    null
  )
}

output "public_frontend_ip_resource_id" {
  description = "Resource ID of the public IP attached to the gateway; null when the gateway is private-only."
  value       = try(var.public_frontend_ip_configuration.ip_address_resource_id, null)
}

output "frontend_ip_configuration_names" {
  description = "Map of frontend mode (`public`, `private`) to the Application Gateway frontend block name. Nulls are filtered out — keys are only present for frontends that were actually configured."
  value = {
    for k, v in {
      public  = local.public_frontend_ip_config_name
      private = local.private_frontend_ip_config_name
    } : k => v if v != null
  }
}

output "active_frontend_ip_configuration_name" {
  description = "Name of the bootstrap http_listener's frontend. AGIC may reshuffle which frontend serves which listener at runtime via annotations; this output reflects the module's initial wiring only."
  value       = local.active_frontend_ip_configuration_name
}
