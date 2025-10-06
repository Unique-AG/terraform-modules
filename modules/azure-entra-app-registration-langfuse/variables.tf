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
    secret_name     = optional(string, "langfuse-client-secret")
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

variable "app_role" {
  description = "The app role to assign to the application. All more detailed roles have to be assigned manually. "
  type = object({
    role_id      = optional(string, "6a902661-cfac-44f4-846c-bc5ceaa012d4")
    description  = optional(string, "User, allows to use the application or login without any additional permissions.")
    display_name = optional(string, "User")
    value        = optional(string, "user")
    members      = optional(set(string), [])
  })
}

variable "role_assignments_required" {
  description = "Whether role assignments are required to be able to use the app. Least privilege principle encourages true."
  type        = bool
  default     = true
}