output "namespace" {
  description = "Details of the Event Hub namespace."
  value       = azurerm_eventhub_namespace.namespace
}

output "namespace_authorization_rules" {
  description = "Authorization rules created at the namespace scope."
  value = merge(
    var.namespace.create_listen_rule ? {
      listen = azurerm_eventhub_namespace_authorization_rule.listen[0]
    } : {},
    var.namespace.create_send_rule ? {
      send = azurerm_eventhub_namespace_authorization_rule.send[0]
    } : {},
    var.namespace.create_manage_rule ? {
      manage = azurerm_eventhub_namespace_authorization_rule.manage[0]
    } : {},
    {
      for key, rule in azurerm_eventhub_namespace_authorization_rule.custom :
      key => rule
    }
  )
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

output "client_id" {
  description = "The client ID of the underlying Azure Entra App Registration."
  value       = var.receiver_service_principal != null ? azuread_application.sp_data_receiver[0].client_id : null
}

output "object_id" {
  description = "The object ID of the matching Service Principal to be used for effective role assignments."
  value       = var.receiver_service_principal != null ? azuread_service_principal.sp_data_receiver[0].object_id : null
}
