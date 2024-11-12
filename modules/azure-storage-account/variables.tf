
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
  default     = "TLS1_2"
}

variable "account_kind" {
  description = "Kind to use for the storage account. Learn more about storage account kinds in the Azure Docs."
  default     = "StorageV2"
}

variable "account_tier" {
  description = "Tier to use for the storage account. Learn more about storage account tiers in the Azure Docs."
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Type of replication to use for this storage account. Learn more about storage account replication types in the Azure Docs."
  default     = "ZRS"
}

variable "access_tier" {
  description = "Type of replication to use for this storage account. Learn more about storage account access tiers in the Azure Docs. Defaults to Cool as the difference is negligible for most use cases but is more cost-efficient."
  default     = "Cool"
}

variable "is_nfs_mountable" {
  description = "Enable NFSv3 and HNS protocol for the storage account in order to be mounted to AKS/nodes."
  type        = bool
  default     = false
}

variable "identity_ids" {
  description = "List of managed identity IDs to assign to the storage account."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "cors_rules" {
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

variable "customer_managed_key" {
  description = "Customer managed key properties for the storage account. Refer to the readme for more information on what is needed to enable customer-managed key encryption. It is recommended to not use key_version unless you have a specific reason to do so as leaving it out will allow automatic key rotation."
  type = object({
    key_vault_uri = string
    key_name      = string
    key_version   = optional(string, null)
  })
  default  = null
  nullable = true
}

variable "storage_management_policy_default" {
  description = "A simple abstraction of the most common properties for storage management lifecycle policies. If the simple implementation does not meet your needs, please open an issue. If you use this module to safe files that are rarely to never accessed again, opt for a very aggressive policy (starting already cool and archiving early). If you want to implement your own storage management policy, disable the default and use the output storage_account_id to implement your own policies."
  type = object({
    enabled                                  = optional(bool, true)
    deleted_retain_days                      = optional(number, 7)
    restorable_days                          = optional(number, 6)
    container_deleted_retain_days            = optional(number, 7)
    blob_to_cool_after_last_modified_days    = optional(number, 10)
    blob_to_cold_after_last_modified_days    = optional(number, 50)
    blob_to_archive_after_last_modified_days = optional(number, 100)
    blob_to_deleted_after_last_modified_days = optional(number, 730)
  })
  default = {
    enabled                                  = true
    deleted_retain_days                      = 7
    restorable_days                          = 6
    container_deleted_retain_days            = 7
    blob_to_cool_after_last_modified_days    = 10
    blob_to_cold_after_last_modified_days    = 50
    blob_to_archive_after_last_modified_days = 100
    blob_to_deleted_after_last_modified_days = 730
  }
  nullable = false
}
