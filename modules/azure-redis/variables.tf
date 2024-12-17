
variable "name" {
  description = "Name of the storage account."
  type        = string
  nullable    = false
}

variable "location" {
  description = "Location of the resources."
  type        = string
  nullable    = false
}

variable "resource_group_name" {
  description = "Name of the resource group to put the resources in."
  type        = string
  nullable    = false
}

variable "tags" {
  description = "Tags for the resources."
  type        = map(string)
  default     = {}
}

variable "min_tls_version" {
  description = "Minimum TLS version supported by the storage account."
  type        = string
  default     = "1.2"
}

variable "capacity" {
  description = "The size of the Redis cache to deploy. Valid values for a SKU family of C (Basic/Standard) are 0, 1, 2, 3, 4, 5, 6, and for P (Premium) family are 1, 2, 3, 4, 5."
  type        = number
  default     = 1
}

variable "family" {
  description = "The SKU family/pricing group to use. Valid values are C (for Basic/Standard SKU family) and P (for Premium)"
  type        = string
  default     = "C"
}

variable "sku_name" {
  description = "The SKU of Redis to use. Possible values are Basic, Standard and Premium"
  type        = string
  default     = "Standard"
}

variable "public_network_access_enabled" {
  description = "Whether or not public network access is allowed for this Redis Cache"
  type        = bool
  default     = false
}