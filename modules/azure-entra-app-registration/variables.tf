variable "display_name" {
  type        = string
  description = "The displayed name in Entra"
}

variable "client_secret_generation_config" {
  type = object({
    enabled     = bool
    keyvault_id = optional(string)
    secret_name = optional(string, "entra-app-client-secret")
  })
  description = "When enabled, a client secret will be generated and stored in the keyvault."
  default = {
    enabled = false
  }

  validation {
    condition     = !var.client_secret_generation_config.enabled || (var.client_secret_generation_config.enabled && var.client_secret_generation_config.keyvault_id != null)
    error_message = "When client_secret_generation_config.enabled is true, keyvault_id must be provided."
  }
}

variable "redirect_uris" {
  description = "Authorized redirects"
  type        = list(string)
  default     = []
}

variable "redirect_uris_public_native" {
  description = "Public client/native (mobile & desktop) redirects"
  type        = list(string)
  default     = []
}

variable "owner_user_object_ids" {
  type    = list(string)
  default = []
}

variable "required_resource_access_list" {
  description = "A map of resource_app_ids with their access configurations."
  type = map(list(object({
    id   = string
    type = string
  })))
  default = {
    "00000003-0000-0000-c000-000000000000" = [ # Microsoft Graph API
      {
        id   = "14dad69e-099b-42c9-810b-d002981feec1" # profile
        type = "Scope"
      },
      {
        id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
        type = "Scope"
      },
      {
        id   = "37f7f235-527c-4136-accd-4a02d197296e" # openid
        type = "Scope"
      },
      {
        id   = "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0" # email
        type = "Scope"
      },
    ],
  }
}

variable "maintainers_principal_object_ids" {
  type        = list(string)
  description = "The object ids of the user/groups/service_principal "
}
