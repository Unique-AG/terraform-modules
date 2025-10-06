variable "display_name" {
  description = "The display name for the Azure AD application registration."
  type        = string
}

variable "sign_in_audience" {
  description = "The Microsoft identity platform audiences that are supported by this application. Valid values are 'AzureADMyOrg', 'AzureADMultipleOrgs', 'AzureADandPersonalMicrosoftAccount', or 'PersonalMicrosoftAccount'. We default to AzureADMultipleOrgs as it's the most common use case. Stricter setups can revert back to 'AzureADMyOrg'."
  type        = string
  default     = "AzureADMultipleOrgs"
}


variable "client_secret_generation_config" {
  type = object({
    keyvault_id     = optional(string)
    secret_name     = optional(string, "langfuse")
    expiration_date = optional(string, "2099-12-31T23:59:59Z")
  })
  description = "When enabled, a client secret will be generated and stored in the keyvault."
  default     = {}
}

variable "redirect_uris" {
  description = "Authorized redirects. Has to be in format https://yourapplication.com/api/auth/callback/azure-ad"
  type        = list(string)
}

variable "homepage_url" {
  description = "The homepage url of the app."
  type        = string
}

variable "allowed_groups" {
  description = "Set of group object IDs that are allowed to access the application. All members of these groups will have access with default access (no custom roles)."
  type        = set(string)
  default     = []
}

variable "role_assignments_required" {
  description = "Whether role assignments are required to be able to use the app. Least privilege principle encourages true. When true, only members of groups in 'allowed_groups' can access the application."
  type        = bool
  default     = true
}