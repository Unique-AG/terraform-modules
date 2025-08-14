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

variable "backend_http_settings_protocol" {
  description = "Protocol for backend HTTP settings"
  type        = string
  default     = "Http"
  validation {
    condition     = contains(["Http", "Https"], var.backend_http_settings_protocol)
    error_message = "Backend HTTP settings protocol must be either 'Http' or 'Https'."
  }
}

variable "backend_http_settings_port" {
  description = "Port for backend HTTP settings"
  type        = number
  default     = 80
  validation {
    condition     = var.backend_http_settings_port >= 1 && var.backend_http_settings_port <= 65535
    error_message = "Backend HTTP settings port must be between 1 and 65535."
  }
}

variable "backend_http_settings_trusted_root_certificate_names" {
  description = "Names of trusted root certificates to associate with backend HTTP settings"
  type        = list(string)
  default     = []
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
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/web_application_firewall_policy#file_upload_limit_in_mb-1
  description = "The file upload limit in MB. This is the maximum size of the file that can be uploaded through the application gateway. Revert it to 100 if you want to adhere to the policies defaults."
  type        = number
  default     = 512
}

variable "zones" {
  description = "Specifies a list of Availability Zones in which this Application Gateway should be located. Changing this forces a new Application Gateway to be created."
  type        = list(string)
  default     = null
  nullable    = true
}

/**
* These two next variables are only needed until Unique AI internally supports multi-part
* uploads.
*/
variable "max_request_body_size_in_kb" {
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/web_application_firewall_policy
  description = "The max request body size in KB. This defaults to the maximum to support as many use cases as possible. Lower it back to its default of 128 if you want to adhere to the policies defaults."
  type        = number
  default     = 2000
}

variable "max_request_body_size_exempted_request_uris" {
  # Unblock Ingestion Upload if the max request body size is greater than 2000KB
  # Note that this is now a green card to allowlist any URL.
  # This rules priority is 5, so it will be applied after all other rules (incl. e.g. IP-based rules).
  # https://stackoverflow.com/questions/70975624/azure-web-application-firewall-waf-not-diferentiating-file-uploads-from-normal/72184077#72184077
  # https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/application-gateway-waf-request-size-limits
  description = "The request URIs that are exempted from the max request body size. This is a list of request URIs that are exempted from the max request body size. If the WAF is running in Prevention mode, these URIs will be exempted from the max request body size. This setting has no effect if the WAF is running in Detection mode or the gateway isn't using the WAF_v2 SKU."
  type        = list(string)
  default     = ["/scoped/ingestion/upload", "/ingestion/v1/content"]
}

/**
* The two previous variables are only needed until Unique AI internally supports multi-part * uploads.
*/

variable "trusted_root_certificates" {
  description = "Configuration for trusted root certificates (e.g., for private CAs). Each certificate will be uploaded to the Application Gateway and can be referenced in backend HTTP settings."
  type = list(object({
    name             = string
    certificate_path = string
  }))
  default = []

  validation {
    condition = alltrue([
      for cert in var.trusted_root_certificates :
      length(cert.name) > 0 && length(cert.name) <= 80
    ])
    error_message = "Each trusted root certificate name must be between 1 and 80 characters long."
  }

  validation {
    condition = alltrue([
      for cert in var.trusted_root_certificates :
      can(regex("\\.(cer|crt|pem)$", cert.certificate_path))
    ])
    error_message = "Certificate file must have a .cer, .crt, or .pem extension."
  }
}
