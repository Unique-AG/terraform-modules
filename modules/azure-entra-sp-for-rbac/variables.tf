variable "display_name" {
  description = "The display name for the Create-For-RBAC Service Principal."
  type        = string
}

variable "client_secret_generation_config" {
  type = object({
    keyvault_id     = optional(string)
    secret_name     = optional(string, "sp-create-for-rbac")
    expiration_date = optional(string, "2099-12-31T23:59:59Z")
  })
  description = "When enabled, a client secret will be generated and stored in the keyvault."
  default     = {}
}
