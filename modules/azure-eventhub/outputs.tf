output "namespace" {
  description = "Details of the Event Hub namespace."
  value       = azurerm_eventhub_namespace.namespace
}

output "namespace_authorization_rules" {
  description = "Authorization rules created at the namespace scope (only id, name, and resource group name)."
  value = {
    for key, rule in merge(
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
    ) :
    key => {
      id                  = rule.id
      name                = rule.name
      resource_group_name = rule.resource_group_name
    }
  }
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
