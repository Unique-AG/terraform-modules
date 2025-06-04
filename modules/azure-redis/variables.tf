variable "name" {
  description = "Name of the Redis Cache instance."
  type        = string
  nullable    = false
}

variable "location" {
  description = "Azure region where the Redis Cache will be deployed."
  type        = string
  nullable    = false
}

variable "resource_group_name" {
  description = "Name of the resource group where the Redis Cache will be deployed."
  type        = string
  nullable    = false
}

variable "tags" {
  description = "Tags to apply to the Redis Cache resource."
  type        = map(string)
  default     = {}
}

variable "min_tls_version" {
  description = "Minimum TLS version supported by the Redis Cache. Valid values are 1.0, 1.1, and 1.2."
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

variable "key_vault_id" {
  description = "The ID of the Key Vault where the secrets will be stored"
  default     = null
  type        = string
}

variable "password_secret_name" {
  description = "Name of the secret containing the password"
  default     = null
  type        = string
}

variable "host_secret_name" {
  description = "Name of the secret containing the host"
  default     = null
  type        = string
}

variable "port_secret_name" {
  description = "Name of the secret containing the port"
  default     = null
  type        = string
}

variable "private_endpoint" {
  description = "Configuration for private endpoint to connect to the Redis Cache. When specified, creates a private endpoint in the specified subnet and links it to the provided private DNS zone."
  type = object({
    subnet_id           = string
    private_dns_zone_id = string
  })
  default = null
}