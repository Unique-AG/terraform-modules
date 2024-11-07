variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "my-resource-group"
}

variable "storage_account_name" {
  description = "Name of the storage account"
  type        = string
  default     = "my-storage-account"
}

variable "location" {
  description = "Location of the resource"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Tags for the resource"
  type        = map(string)
  default     = {}
}

variable "min_tls_version" {
  description = "Minimum TLS version supported by the storage account"
  type        = string
  default     = "TLS1_2"
}

variable "retention_period_days" {
  description = "Number of days to retain the storage objects."
  type        = number
  default     = 30
}

variable "customer_managed_key_size" {
  description = "The size of the customer-managed key for the storage account."
  type        = number
  default     = 2048
}

variable "key_vault_id" {
  description = "The ID of the key vault"
  type        = string
  default     = "my-key-vault-id"
}

variable "storage_account_cors_rules" {
  description = "CORS rules for the storage account"
  type = list(object({
    allowed_origins    = list(string)
    allowed_methods    = list(string)
    allowed_headers    = list(string)
    exposed_headers    = list(string)
    max_age_in_seconds = number
  }))
  default = []
}