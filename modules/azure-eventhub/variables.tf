variable "location" {
  description = "Azure region where the Event Hub namespace is deployed."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group that will contain the Event Hub namespace."
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources created by this module."
  type        = map(string)
  default     = {}
}

variable "namespace" {
  description = "Configuration for the Event Hub namespace."
  type = object({
    name                          = string
    sku                           = optional(string, "Standard")
    capacity                      = optional(number)
    auto_inflate_enabled          = optional(bool, true)
    maximum_throughput_units      = optional(number)
    minimum_tls_version           = optional(string, "1.2")
    public_network_access_enabled = optional(bool, true)
    local_authentication_enabled  = optional(bool, true)
    identity = optional(object({
      type         = string
      identity_ids = optional(list(string), [])
    }))
    customer_managed_key = optional(object({
      key_vault_key_ids         = list(string)
      user_assigned_identity_id = optional(string)
    }))
    network_rules = optional(object({
      default_action                 = optional(string, "Deny")
      trusted_service_access_enabled = optional(bool, false)
      public_network_access_enabled  = optional(bool, true)
      ip_rules = optional(list(object({
        ip_mask = string
        action  = optional(string, "Allow")
      })), [])
      virtual_network_rules = optional(list(object({
        subnet_id                                       = string
        ignore_missing_virtual_network_service_endpoint = optional(bool, false)
      })), [])
    }))
    create_listen_rule = optional(bool, true)
    create_send_rule   = optional(bool, true)
    create_manage_rule = optional(bool, false)
    tags               = optional(map(string), {})
  })
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{4,48}[a-zA-Z0-9]$", var.namespace.name))
    error_message = "The namespace name can contain only letters, numbers and hyphens, must start with a letter, end with a letter or number, and be between 6 and 50 characters long."
  }
  default = {
    name = "eventhub-namespace-001"
  }
}

variable "namespace_authorization_rules" {
  description = "Map of custom authorization rules to create at the namespace level."
  type = map(object({
    name   = string
    listen = optional(bool, false)
    send   = optional(bool, false)
    manage = optional(bool, false)
  }))
  default = {}
}

variable "eventhubs" {
  description = "Map of Event Hubs to create within the namespace."
  type = map(object({
    name              = string
    partition_count   = optional(number, 16)
    message_retention = optional(number, 7)
    status            = optional(string, "Active")
    capture_description = optional(object({
      enabled             = bool
      encoding            = optional(string)
      interval_in_seconds = optional(number)
      size_limit_in_bytes = optional(number)
      skip_empty_archives = optional(bool, true)
      destination = object({
        name                = optional(string, "EventHubArchive.AzureBlockBlob")
        storage_account_id  = string
        blob_container_name = string
        archive_name_format = optional(string, "{Namespace}_{EventHub}_{PartitionId}_{Year}_{Month}_{Day}_{Hour}_{Minute}")
      })
    }))
    consumer_groups = optional(map(object({
      name          = string
      user_metadata = optional(string)
    })), {})
    tags = optional(map(string), {})
  }))
  validation {
    condition = alltrue([
      for hub_key, hub_value in var.eventhubs :
      can(regex("^[a-zA-Z][a-zA-Z0-9-]{4,48}[a-zA-Z0-9]$", coalesce(hub_value.name, hub_key)))
    ])
    error_message = "Each event hub name can contain only letters, numbers and hyphens, must start with a letter, end with a letter or number, and be between 6 and 50 characters long."
  }
  validation {
    condition     = var.eventhubs != null && length(var.eventhubs) > 0
    error_message = "At least one event hub must be defined."
  }
  default = {
    eventhub-001 = {
      name = "eventhub-001"
    }
  }
}