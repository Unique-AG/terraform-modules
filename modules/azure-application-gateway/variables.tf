variable "autoscale_configuration" {
  description = "Configuration for the autoscale configuration"
  type = object({
    min_capacity = number
    max_capacity = number
  })
  default = {
    min_capacity = 1
    max_capacity = 10
  }

  validation {
    condition     = var.autoscale_configuration.min_capacity >= 0
    error_message = "The min_capacity must be at least 0."
  }

  validation {
    condition     = var.autoscale_configuration.max_capacity <= 125
    error_message = "The max_capacity must be at most 125."
  }

  validation {
    condition     = var.autoscale_configuration.max_capacity > var.autoscale_configuration.min_capacity
    error_message = "The max_capacity must be greater than min_capacity."
  }
}

variable "backend_address_pool" {
  description = "Configuration for the backend_address_pool"
  type = object({
    explicit_name = optional(string)
  })
  default = {}
}

variable "backend_http_settings" {
  description = "Configuration for the backend_http_settings"
  type = object({
    explicit_name         = optional(string)
    cookie_based_affinity = optional(string, "Disabled")
    port                  = optional(number, 80)
    protocol              = optional(string, "Http")
    request_timeout       = optional(number, 60)
  })
  default = {}

  validation {
    condition     = contains(["Enabled", "Disabled"], var.backend_http_settings.cookie_based_affinity)
    error_message = "The cookie_based_affinity must be either 'Enabled' or 'Disabled'."
  }

  validation {
    condition     = var.backend_http_settings.port >= 1 && var.backend_http_settings.port <= 65535
    error_message = "The port must be between 1 and 65535."
  }

  validation {
    condition     = contains(["Http", "Https"], var.backend_http_settings.protocol)
    error_message = "The protocol must be either 'Http' or 'Https'."
  }

  validation {
    condition     = var.backend_http_settings.request_timeout >= 1 && var.backend_http_settings.request_timeout <= 86400
    error_message = "The request_timeout must be between 1 and 86400 seconds."
  }
}

variable "explicit_name" {
  description = "Name for the Gateway if <name_prefix>-appgw is not desired."
  type        = string
  default     = null
}

variable "frontend_port" {
  description = "Settings for the frontend port."
  type = object({
    explicit_name = optional(string)
    port          = optional(number, 80)
  })
  default = {}

  validation {
    condition     = var.frontend_port.port >= 1 && var.frontend_port.port <= 65535
    error_message = "The port must be between 1 and 65535."
  }
}

variable "gateway_ip_configuration" {
  description = "Defines which subnet the Application Gateway will be deployed in and under which name."
  type = object({
    explicit_name      = optional(string)
    subnet_resource_id = string
  })

  validation {
    condition     = can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft.Network/virtualNetworks/.+/subnets/.+$", var.gateway_ip_configuration.subnet_resource_id))
    error_message = "The subnet_resource_id must be a valid Azure subnet resource ID."
  }
}

variable "global_request_buffering_enabled" {
  description = "Enable request buffering, setting it to false is incompatible with WAF_v2 SKU. Refer to https://learn.microsoft.com/en-us/azure/application-gateway/proxy-buffers#request-buffer to understand the implications."
  type        = bool
  default     = true

  validation {
    condition     = var.global_request_buffering_enabled == true || var.sku.tier != "WAF_v2"
    error_message = "Request buffering cannot be disabled when using WAF_v2 SKU."
  }
}

variable "global_response_buffering_enabled" {
  description = "Enable response buffering, refer to https://learn.microsoft.com/en-us/azure/application-gateway/proxy-buffers#response-buffer to understand the implications. Defaults to false to support Unique AI server-sent events."
  type        = bool
  default     = false
}

variable "http_listener" {
  description = "Configuration for the http_listener"
  type = object({
    explicit_name = optional(string)
  })
  default = {}
}

variable "monitor_diagnostic_setting" {
  description = "Configuration for the application gateway diagnostic setting"
  type = object({
    name                       = optional(string)
    log_analytics_workspace_id = string
    enabled_log = optional(list(object({
      category_group = string
    })))
  })
  default = null
}

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
  validation {
    condition     = length(var.name_prefix) > 0 && length(var.name_prefix) <= 20
    error_message = "The name_prefix must be between 1 and 20 characters long."
  }
}

variable "private_frontend_ip_configuration" {
  description = "Configuration for the frontend_ip_configuration that leverages a private IP address."
  type = object({
    explicit_name           = optional(string)
    ip_address_resource_id  = string
    address_allocation      = optional(string, "Static")
    subnet_resource_id      = string
    is_active_http_listener = optional(bool, false)
  })
  default = null
}

variable "public_frontend_ip_configuration" {
  description = "Configuration for the frontend_ip_configuration that leverages a public IP address. Might become nullable once https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-private-deployment leaves Preview."
  type = object({
    explicit_name           = optional(string)
    ip_address_resource_id  = string
    ip_address              = optional(string)
    is_active_http_listener = optional(bool, true)
  })

  validation {
    condition     = can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft.Network/publicIPAddresses/.+$", var.public_frontend_ip_configuration.ip_address_resource_id))
    error_message = "The ip_address_resource_id must be a valid Azure public IP address resource ID."
  }

  validation {
    condition     = var.public_frontend_ip_configuration.ip_address == null || can(cidrhost(format("%s/32", var.public_frontend_ip_configuration.ip_address), 0))
    error_message = "The ip_address must be a valid IPv4 address."
  }
}

variable "request_routing_rule" {
  description = "Configuration for the request_routing_rule"
  type = object({
    explicit_name = optional(string)
  })
  default = {}
}

variable "resource_group" {
  description = "The resource group to deploy the gateway to."
  type = object({
    name     = string
    location = string
  })

  validation {
    condition     = length(var.resource_group.name) > 0 && length(var.resource_group.name) <= 90
    error_message = "The resource group name must be between 1 and 90 characters long."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]+$", var.resource_group.name))
    error_message = "The resource group name can only contain alphanumeric characters, periods, underscores, and hyphens."
  }
}

variable "sku" {
  description = "The SKU of the gateway"
  type = object({
    name = string
    tier = string
  })
  default = {
    name = "Standard_v2"
    tier = "Standard_v2"
  }

  validation {
    condition = contains([
      "Standard_Small", "Standard_Medium", "Standard_Large",
      "Standard_v2", "WAF_Medium", "WAF_Large", "WAF_v2"
    ], var.sku.name)
    error_message = "The SKU name must be one of: Standard_Small, Standard_Medium, Standard_Large, Standard_v2, WAF_Medium, WAF_Large, WAF_v2."
  }

  validation {
    condition = contains([
      "Standard", "Standard_v2", "WAF", "WAF_v2"
    ], var.sku.tier)
    error_message = "The SKU tier must be one of: Standard, Standard_v2, WAF, WAF_v2."
  }

  validation {
    condition = (
      (var.sku.tier == "Standard" && contains(["Standard_Small", "Standard_Medium", "Standard_Large"], var.sku.name)) ||
      (var.sku.tier == "Standard_v2" && var.sku.name == "Standard_v2") ||
      (var.sku.tier == "WAF" && contains(["WAF_Medium", "WAF_Large"], var.sku.name)) ||
      (var.sku.tier == "WAF_v2" && var.sku.name == "WAF_v2")
    )
    error_message = "The SKU name and tier combination is invalid."
  }
}

variable "ssl_policy" {
  description = "SSL policy configuration"
  type = object({
    name = string
    type = string
  })
  default = {
    name = "AppGwSslPolicy20220101"
    type = "Predefined"
  }
  nullable = false

  validation {
    condition     = contains(["Predefined", "Custom"], var.ssl_policy.type)
    error_message = "The ssl_policy.type must be either 'Predefined' or 'Custom'."
  }
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
}

variable "zones" {
  description = "Specifies a list of Availability Zones in which this Application Gateway should be located. Changing this forces a new Application Gateway to be created."
  type        = list(string)
  default     = null
}
