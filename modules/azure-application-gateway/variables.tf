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
  default     = "eastus"

  validation {
    condition     = length(var.resource_group_location) > 0
    error_message = "The resource group location must not be empty."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
  default     = "test-rg"

  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "The resource group name must not be empty."
  }
}

variable "ip_name" {
  description = "The name of the public IP address."
  type        = string
  default     = "default-public-ip-name"
  validation {
    condition     = length(var.ip_name) > 0
    error_message = "The IP name must not be empty."
  }
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default = {
    environment = "test"
    cost_center = "12345"
  }

  validation {
    condition     = length(var.tags) > 0
    error_message = "The tags map must not be empty."
  }
}

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
  default     = "myapp"

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
  default     = "default-subnet-id"
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