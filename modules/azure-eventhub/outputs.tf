output "namespace" {
  description = "Details of the Event Hub namespace."
  value       = azurerm_eventhub_namespace.namespace
}

output "namespace_authorization_rules" {
  description = "Authorization rules created at the namespace scope (only id, name, and resource group name)."
  value = {
    for key, rule in azurerm_eventhub_namespace_authorization_rule.rules :
    key => rule
  }
  sensitive = true
}

output "eventhubs" {
  description = "Map of Event Hubs created by this module."
  value = {
    for key, hub in azurerm_eventhub.eventhub :
    key => hub
  }
}

output "eventhub_consumer_groups" {
  description = "Consumer groups created for each Event Hub."
  value = {
    for key, group in azurerm_eventhub_consumer_group.consumer_group :
    key => group
  }
}

output "private_endpoint" {
  description = "Private endpoint of the Event Hub namespace (id and private IP address), or null if not configured."
  value = var.private_endpoint == null ? null : {
    id                 = azurerm_private_endpoint.pe[0].id
    private_ip_address = azurerm_private_endpoint.pe[0].private_service_connection[0].private_ip_address
  }
}
