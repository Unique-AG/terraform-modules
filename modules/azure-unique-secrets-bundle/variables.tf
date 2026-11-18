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
    google-search-api-key               = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    litellm-anthropic-api-key           = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    litellm-bedrock-access-key          = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    litellm-bedrock-secret-key          = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    litellm-gemini-api-key              = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    litellm-openai-api-key              = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    litellm-together-ai-api-key         = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    litellm-voyage-api-key              = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    litellm-xai-api-key                 = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    mcp-hub-default-oauth-client-id     = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    mcp-hub-default-oauth-client-secret = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    mip-azure-client-id                 = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    mip-azure-client-secret             = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    mip-azure-tenant-id                 = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    quartr-api-creds                    = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    six-api-creds                       = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
    zitadel-scope-mgmt-pat              = { create = true, expiration_date = "2099-12-31T23:59:59Z" }
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
    sops_age_key_custom_assistant_1       = { create = true, name = "sops-age-key-custom-assistant-1", content_type = "text/plain", special = false, rotation_counter = 0, expiration_date = "2099-12-31T23:59:59Z" }
    sops_age_key_custom_assistant_2       = { create = true, name = "sops-age-key-custom-assistant-2", content_type = "text/plain", special = false, rotation_counter = 0, expiration_date = "2099-12-31T23:59:59Z" }
  }
}

variable "activity_records_keys" {
  description = <<-EOT
    Versions of the Activity Records keys, stored in `key_vault_id` (defaults to `kv_id_sensitive`). Each version gets its own secrets, suffixed with the version, e.g. `activity-records-fingerprint-secret-1`.

    - `fingerprint_secret_versions`: HMAC secrets (32 random bytes, base64) for the row level fingerprints. A fingerprint can only be verified with the secret that created it, so every version must be kept forever.
    - `seal_key_versions`: ECDSA P-256 (ES256) key pairs that seal a batch of rows every minute, stored as `activity-records-seal-private-key-<version>` (PKCS#8 PEM) and `activity-records-seal-public-key-<version>` (PEM). A seal is verified with the public key only, so it must be kept forever. Losing an old private key only stops new seals with it.

    Rotate by appending a new version and pointing the workload to it, never by removing or replacing one. The generated keys have `prevent_destroy`, so removing a version fails on purpose. Set a list to `[]` before the first apply to not create the keys.
  EOT
  type = object({
    key_vault_id                = optional(string)
    fingerprint_secret_versions = optional(set(number), [1])
    seal_key_versions           = optional(set(number), [1])
  })
  default = {}

  validation {
    condition = alltrue([
      for v in setunion(var.activity_records_keys.fingerprint_secret_versions, var.activity_records_keys.seal_key_versions) : v >= 1 && floor(v) == v
    ])
    error_message = "Versions must be positive integers."
  }
}
