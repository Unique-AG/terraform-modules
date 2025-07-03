variable "kv_id_sensitive" {
  description = "The ID of the sensitive key vault, all automatically generated secrets will be stored here."
  type        = string
}

variable "kv_id_core" {
  description = "The ID of the core key vault, all manually created secrets will be placed here."
  type        = string
}

variable "default_secrets_placeholders" {
  description = "List of secrets that are manually created and need to be placed in the core key vault. The manual- prefix is prepended automatically."
  type = map(object({
    create          = optional(bool, true)
    expiration_date = optional(string, "2099-12-31T23:59:59Z")
  }))
  default = {
    google-search-api-key       = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    litellm-anthropic-api-key   = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    litellm-bedrock-access-key  = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    litellm-bedrock-secret-key  = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    litellm-gemini-api-key      = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    litellm-openai-api-key      = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    litellm-together-ai-api-key = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    litellm-voyage-api-key      = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    quartr-api-creds            = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    zitadel-scope-mgmt-pat      = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
  }
}
variable "extra_secrets_placeholders" {
  description = "List of secrets that are additionally, manually created and need to be placed in the core key vault. The manual- prefix is prepended automatically."
  type = map(object({
    expiration_date = optional(string, "2099-12-31T23:59:59Z")
  }))
  default = {}
}

variable "secrets_to_create" {
  description = "List of secrets that are automatically generated and need to be placed in the sensitive key vault. Increment a counter to rotate the secret."
  type = map(object({
    create           = optional(bool, true)
    name             = optional(string)
    content_type     = optional(string, "text/plain")
    special          = optional(bool, false)
    length           = optional(number)
    rotation_counter = optional(number, 0)
    expiration_date  = optional(string, "2099-12-31T23:59:59Z")
  }))
  default = {
    encryption_app_repository             = { create = true, name = "encryption-app-repository", content_type = "text/plain", special = false, rotation_counter = 0, expiration_date = "2099-12-31T23:59:59Z" }
    hex_encryption_key_ingestion          = { create = true, name = "encryption-key-ingestion", content_type = "text/hex", rotation_counter = 0, expiration_date = "2099-12-31T23:59:59Z" }
    hex_encryption_key_node_chat_lxm      = { create = true, name = "encryption-key-node-chat-lxm", content_type = "text/hex", rotation_counter = 0, expiration_date = "2099-12-31T23:59:59Z" }
    hex_encryption_key_scope_management_1 = { create = true, name = "encryption-key-scope-management-1", content_type = "text/hex", rotation_counter = 0, expiration_date = "2099-12-31T23:59:59Z" }
    hex_encryption_key_scope_management_2 = { create = true, name = "encryption-key-scope-management-2", content_type = "text/hex", rotation_counter = 0, expiration_date = "2099-12-31T23:59:59Z" }
    litellm_master_key                    = { create = true, name = "litellm-master-key", content_type = "text/plain", special = false, length = 32, rotation_counter = 0, expiration_date = "2099-12-31T23:59:59Z" }
    litellm_salt_key                      = { create = true, name = "litellm-salt-key", content_type = "text/plain", special = false, length = 32, rotation_counter = 0, expiration_date = "2099-12-31T23:59:59Z" }
    rabbitmq_password_chat                = { create = true, name = "rabbitmq-password-chat", content_type = "text/plain", special = false, length = 24, rotation_counter = 0, expiration_date = "2099-12-31T23:59:59Z" }
    zitadel_db_user_password              = { create = true, name = "zitadel-db-user-password", content_type = "text/plain", special = false, length = 32, rotation_counter = 0, expiration_date = "2099-12-31T23:59:59Z" }
    zitadel_main_key                      = { create = true, name = "zitadel-main-key", content_type = "text/plain", special = false, length = 32, rotation_counter = 0, expiration_date = "2099-12-31T23:59:59Z" }
  }
}
