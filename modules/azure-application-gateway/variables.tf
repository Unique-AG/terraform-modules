variable "gateway_sku" {
  description = "The SKU of the gateway"
  type        = string
  default     = "Standard_v2"
  validation {
    condition     = length(var.gateway_sku) > 0
    error_message = "The gateway_sku must not be empty."
  }
}

variable "gateway_tier" {
  description = "The tier of the gateway"
  type        = string
  default     = "Standard_v2"
  validation {
    condition     = length(var.gateway_tier) > 0
    error_message = "The gateway_tier must not be empty."
  }
}

variable "gateway_mode" {
  description = "The mode of the gateway (Prevention or Detection)"
  type        = string
  default     = "Prevention"
  validation {
    condition     = contains(["Prevention", "Detection"], var.gateway_mode)
    error_message = "The gateway_mode must be either 'Prevention' or 'Detection'."
  }
}


variable "resource_group_location" {
  description = "The location of the resource group."
  type        = string

  validation {
    condition     = length(var.resource_group_location) > 0
    error_message = "The resource group location must not be empty."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string

  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "The resource group name must not be empty."
  }
}

variable "ip_name" {
  description = "The name of the public IP address."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  validation {
    condition     = length(var.tags) > 0
    error_message = "The tags map must not be empty."
  }
}

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
  validation {
    condition     = length(var.name_prefix) > 0 && length(var.name_prefix) <= 20
    error_message = "The name_prefix must be between 1 and 20 characters long."
  }
}

variable "min_capacity" {
  description = "Minimum capacity for autoscaling"
  type        = number
  default     = 1

  validation {
    condition     = var.min_capacity >= 1
    error_message = "The min_capacity must be at least 1."
  }
}

variable "max_capacity" {
  description = "Maximum capacity for autoscaling"
  type        = number
  default     = 2

  validation {
    condition     = var.max_capacity <= 10
    error_message = "The max_capacity must be smaller than or equal to 10."
  }
}

variable "ssl_policy_name" {
  description = "Name of the SSL policy"
  type        = string
  default     = "AppGwSslPolicy20220101"

  validation {
    condition     = length(var.ssl_policy_name) > 0
    error_message = "The ssl_policy_name must not be empty."
  }
}

variable "ssl_policy_type" {
  description = "Type of the SSL policy"
  type        = string
  default     = "Predefined"

  validation {
    condition     = contains(["Predefined", "Custom"], var.ssl_policy_type)
    error_message = "The ssl_policy_type must be either 'Predefined' or 'Custom'."
  }
}

variable "subnet_appgw" {
  description = "The ID of the subnet for the application gateway"
  type        = string
  validation {
    condition     = length(var.subnet_appgw) > 0
    error_message = "The subnet_appgw must not be empty."
  }
}

variable "private_ip" {
  description = "Private IP address for the frontend IP configuration"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace"
  type        = string
  default     = null
}

variable "public_ip_address_id" {
  description = "The ID of the public IP address"
  type        = string
  default     = ""
}

variable "application_gateway_name" {
  description = "Name for the Gateway"
  type        = string
  default     = null
}

variable "frontend_ip_config_name" {
  description = "Name for the frontend_ip_config"
  type        = string
  default     = null
}

variable "frontend_ip_private_config_name" {
  description = "Name for the frontend_ip_private_config"
  type        = string
  default     = null
}

variable "http_listener_name" {
  description = "Name for the http_listener"
  type        = string
  default     = null
}

variable "backend_http_settings_name" {
  description = "Name for the backend_http_settings"
  type        = string
  default     = null
}

variable "routing_rule_name" {
  description = "Name for the routing_rule"
  type        = string
  default     = null
}

variable "backend_address_pool_name" {
  description = "Name for the backend_address_pool"
  type        = string
  default     = null
}

variable "frontend_port_name" {
  description = "Name for the frontend_port"
  type        = string
  default     = null
}

variable "gw_ip_config_name" {
  description = "Name for the gw_ip_config"
  type        = string
  default     = null
}

variable "agw_diagnostic_name" {
  description = "Name for the agw_diagnostic"
  type        = string
  default     = null
}

variable "response_buffering_enabled" {
  description = "Enable response buffering"
  type        = bool
  default     = false
}

variable "request_buffering_enabled" {
  description = "Enable request buffering"
  type        = bool
  default     = true

  validation {
    condition     = var.request_buffering_enabled == true || var.gateway_sku != "WAF_v2"
    error_message = "Request buffering cannot be disabled when using WAF_v2 SKU."
  }
}

variable "private_frontend_enabled" {
  description = "Enable the private frontend IP configuration for the http listener. If disabled, uses public frontend IP configuration"
  type        = bool
  default     = false
}

variable "file_upload_limit_in_mb" {
  description = "The file upload limit in MB"
  type        = number
  default     = 100
  validation {
    condition     = var.file_upload_limit_in_mb >= 0
    error_message = "The file_upload_limit_in_mb must not be empty."
  }
}

variable "max_request_body_size_in_kb" {
  description = "The max request body size in KB"
  type        = number
  default     = 1024
  validation {
    condition     = var.max_request_body_size_in_kb >= 0
    error_message = "The max_request_body_size_in_kb must not be empty."
  }
}
