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
    "alertmanager-slack-webhook-url" = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    "docker-io-pat"                  = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    "docker-io-username"             = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    "github-app-private-key"         = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    "litellm-anthropic-api-key"      = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    "litellm-bedrock-access-key"     = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    "litellm-bedrock-secret-key"     = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    "litellm-gemini-api-key"         = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    "litellm-openai-api-key"         = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    "litellm-together-ai-api-key"    = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    "litellm-voyage-api-key"         = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    "quartr-api-creds"               = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    "uniqueapp-azurecr-io-password"  = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    "uniqueapp-azurecr-io-username"  = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    "zitadel-scope-mgmt-pat"         = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
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
    rabbitmq_password_chat = object({
      create           = optional(bool, true)
      name             = optional(string, "rabbitmq-password-chat")
      special          = optional(bool, false)
      length           = optional(number, 24)
      rotation_counter = optional(number, 0)
      expiration_date  = optional(string, "2099-12-31T23:59:59Z")
    })
    zitadel_main_key = object({
      create           = optional(bool, true)
      name             = optional(string, "zitadel-main-key")
      special          = optional(bool, false)
      length           = optional(number, 32)
      rotation_counter = optional(number, 0)
      expiration_date  = optional(string, "2099-12-31T23:59:59Z")
    })
    zitadel_db_user_password = object({
      create           = optional(bool, true)
      name             = optional(string, "zitadel-db-user-password")
      special          = optional(bool, false)
      length           = optional(number, 32)
      rotation_counter = optional(number, 0)
      expiration_date  = optional(string, "2099-12-31T23:59:59Z")
    })
    encryption_key_ingestion = object({
      create           = optional(bool, true)
      name             = optional(string, "encryption-key-ingestion")
      byte_length      = optional(number, 32)
      rotation_counter = optional(number, 0)
      expiration_date  = optional(string, "2099-12-31T23:59:59Z")
    })
    encryption_key_node_chat_lxm = object({
      create           = optional(bool, true)
      name             = optional(string, "encryption-key-node-chat-lxm")
      byte_length      = optional(number, 32)
      rotation_counter = optional(number, 0)
      expiration_date  = optional(string, "2099-12-31T23:59:59Z")
    })
    encryption_app_repository = object({
      create           = optional(bool, true)
      name             = optional(string, "encryption-app-repository")
      special          = optional(bool, false)
      length           = optional(number, 32)
      rotation_counter = optional(number, 0)
      expiration_date  = optional(string, "2099-12-31T23:59:59Z")
    })
    litellm_master_key = object({
      create           = optional(bool, true)
      name             = optional(string, "litellm-master-key")
      special          = optional(bool, false)
      length           = optional(number, 32)
      rotation_counter = optional(number, 0)
      expiration_date  = optional(string, "2099-12-31T23:59:59Z")
    })
    litellm_salt_key = object({
      create           = optional(bool, true)
      name             = optional(string, "litellm-salt-key")
      special          = optional(bool, false)
      length           = optional(number, 32)
      rotation_counter = optional(number, 0)
      expiration_date  = optional(string, "2099-12-31T23:59:59Z")
    })
    scope_management_encryption_key_1 = object({
      create           = optional(bool, true)
      name             = optional(string, "scope-management-encryption-key-1")
      byte_length      = optional(number, 32)
      rotation_counter = optional(number, 0)
      expiration_date  = optional(string, "2099-12-31T23:59:59Z")
    })
    scope_management_encryption_key_2 = object({
      create           = optional(bool, true)
      name             = optional(string, "scope-management-encryption-key-2")
      byte_length      = optional(number, 32)
      rotation_counter = optional(number, 0)
      expiration_date  = optional(string, "2099-12-31T23:59:59Z")
    })
  }))
  default = {}
}
