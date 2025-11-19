
locals {
  namespace_tags = merge(
    var.tags,
    var.namespace.tags
  )

  namespace_network_rules = var.namespace.network_rules

  eventhub_consumer_groups = merge([
    for hub_key, hub_value in var.eventhubs : {
      for group_key, group_value in hub_value.consumer_groups :
      "${hub_key}_${group_key}" => {
        hub_key       = hub_key
        name          = coalesce(group_value.name, group_key)
        user_metadata = group_value.user_metadata
      }
    }
  ]...)
}

resource "azurerm_eventhub_namespace" "namespace" {
  name                          = var.namespace.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = var.namespace.sku
  capacity                      = var.namespace.capacity
  auto_inflate_enabled          = var.namespace.auto_inflate_enabled
  maximum_throughput_units      = var.namespace.maximum_throughput_units
  minimum_tls_version           = var.namespace.minimum_tls_version
  public_network_access_enabled = var.namespace.public_network_access_enabled
  local_authentication_enabled  = var.namespace.local_authentication_enabled
  tags                          = local.namespace_tags

  dynamic "identity" {
    for_each = var.namespace.identity == null ? [] : [var.namespace.identity]
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "network_rulesets" {
    for_each = local.namespace_network_rules == null ? [] : [local.namespace_network_rules]
    content {
      default_action                 = network_rulesets.value.default_action
      trusted_service_access_enabled = network_rulesets.value.trusted_service_access_enabled
      dynamic "ip_rule" {
        for_each = network_rulesets.value.ip_rules
        content {
          ip_mask = ip_rule.value.ip_mask
          action  = ip_rule.value.action
        }
      }

      dynamic "virtual_network_rule" {
        for_each = network_rulesets.value.virtual_network_rules
        content {
          subnet_id                                       = virtual_network_rule.value.subnet_id
          ignore_missing_virtual_network_service_endpoint = virtual_network_rule.value.ignore_missing_virtual_network_service_endpoint
        }
      }
    }
  }
}

resource "azurerm_eventhub_namespace_customer_managed_key" "namespace_cmk" {
  count = var.namespace.customer_managed_key == null ? 0 : 1

  eventhub_namespace_id     = azurerm_eventhub_namespace.namespace.id
  key_vault_key_ids         = var.namespace.customer_managed_key.key_vault_key_ids
  user_assigned_identity_id = var.namespace.customer_managed_key.user_assigned_identity_id
}

resource "azurerm_eventhub" "eventhub" {
  for_each = var.eventhubs

  name              = each.value.name
  namespace_id      = azurerm_eventhub_namespace.namespace.id
  partition_count   = each.value.partition_count
  message_retention = each.value.message_retention
  status            = each.value.status

  dynamic "capture_description" {
    for_each = each.value.capture_description == null ? [] : [each.value.capture_description]
    content {
      enabled             = capture_description.value.enabled
      encoding            = capture_description.value.encoding
      interval_in_seconds = capture_description.value.interval_in_seconds
      size_limit_in_bytes = capture_description.value.size_limit_in_bytes
      skip_empty_archives = capture_description.value.skip_empty_archives

      destination {
        name                = capture_description.value.destination.name
        archive_name_format = capture_description.value.destination.archive_name_format
        blob_container_name = capture_description.value.destination.blob_container_name
        storage_account_id  = capture_description.value.destination.storage_account_id
      }
    }
  }
}

resource "azurerm_eventhub_namespace_authorization_rule" "listen" {
  count = var.namespace.create_listen_rule ? 1 : 0

  name                = "${var.namespace.name}-listen"
  namespace_name      = azurerm_eventhub_namespace.namespace.name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = false
  manage              = false
}

resource "azurerm_eventhub_namespace_authorization_rule" "send" {
  count = var.namespace.create_send_rule ? 1 : 0

  name                = "${var.namespace.name}-send"
  namespace_name      = azurerm_eventhub_namespace.namespace.name
  resource_group_name = var.resource_group_name
  listen              = false
  send                = true
  manage              = false
}

resource "azurerm_eventhub_namespace_authorization_rule" "manage" {
  count = var.namespace.create_manage_rule ? 1 : 0

  name                = "${var.namespace.name}-manage"
  namespace_name      = azurerm_eventhub_namespace.namespace.name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = true
  manage              = true
}

resource "azurerm_eventhub_namespace_authorization_rule" "custom" {
  for_each = var.namespace_authorization_rules

  name                = each.value.name
  namespace_name      = azurerm_eventhub_namespace.namespace.name
  resource_group_name = var.resource_group_name
  listen              = each.value.listen
  send                = each.value.send
  manage              = each.value.manage
}

resource "azurerm_eventhub_consumer_group" "consumer_group" {
  for_each = local.eventhub_consumer_groups

  name                = each.value.name
  namespace_name      = azurerm_eventhub_namespace.namespace.name
  eventhub_name       = azurerm_eventhub.eventhub[each.value.hub_key].name
  resource_group_name = var.resource_group_name
  user_metadata       = each.value.user_metadata
}
