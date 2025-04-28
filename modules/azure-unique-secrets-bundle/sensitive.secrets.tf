# ---
# @description Encryption key for app repository
# @length 32 char fix
# @type random_string
# @note Does not match other keys due to legacy implementation reasons
# ---

resource "random_password" "encryption_key_app_repository" {
  keepers = { version = var.secrets_to_create.encryption_app_repository.rotation_counter }
  length  = 32
  special = var.secrets_to_create.encryption_app_repository.special
}
resource "azurerm_key_vault_secret" "encryption_app_repository" {
  count           = var.secrets_to_create.encryption_app_repository.create ? 1 : 0
  name            = var.secrets_to_create.encryption_app_repository.name
  value           = random_password.encryption_key_app_repository.result
  content_type    = var.secrets_to_create.encryption_app_repository.content_type
  key_vault_id    = var.kv_id_sensitive
  expiration_date = var.secrets_to_create.encryption_app_repository.expiration_date
}

# ---
# @description Encryption key for ingestion
# @length 32 byte hex
# @type random_id#hex
# ---
resource "random_id" "hex_encryption_key_ingestion" {
  keepers     = { version = var.secrets_to_create.hex_encryption_key_ingestion.rotation_counter }
  byte_length = 32
}
resource "azurerm_key_vault_secret" "hex_encryption_key_ingestion" {
  count           = var.secrets_to_create.hex_encryption_key_ingestion.create ? 1 : 0
  name            = var.secrets_to_create.hex_encryption_key_ingestion.name
  value           = random_id.hex_encryption_key_ingestion.hex
  content_type    = var.secrets_to_create.hex_encryption_key_ingestion.content_type
  key_vault_id    = var.kv_id_sensitive
  expiration_date = var.secrets_to_create.hex_encryption_key_ingestion.expiration_date
}

# ---
# @description Encryption key for chat lxms
# @length 32 byte hex
# @type random_id#hex
# ---
resource "random_id" "hex_encryption_key_node_chat_lxm" {
  keepers     = { version = var.secrets_to_create.hex_encryption_key_node_chat_lxm.rotation_counter }
  byte_length = 32
}
resource "azurerm_key_vault_secret" "encryption_key_ingestion" {
  count           = var.secrets_to_create.hex_encryption_key_node_chat_lxm.create ? 1 : 0
  name            = var.secrets_to_create.hex_encryption_key_node_chat_lxm.name
  value           = random_id.hex_encryption_key_node_chat_lxm.hex
  content_type    = var.secrets_to_create.hex_encryption_key_node_chat_lxm.content_type
  key_vault_id    = var.kv_id_sensitive
  expiration_date = var.secrets_to_create.hex_encryption_key_node_chat_lxm.expiration_date
}

# ---
# @description Encryption key for scope management 1
# @length 32 byte hex
# @type random_id#hex
# @note Has two keys to rotate zero downtime
# ---
resource "random_id" "hex_scope_management_encryption_key_1" {
  keepers     = { version = var.secrets_to_create.hex_scope_management_encryption_key_1.rotation_counter }
  byte_length = 32
}
resource "azurerm_key_vault_secret" "hex_scope_management_encryption_key_1" {
  count           = var.secrets_to_create.hex_scope_management_encryption_key_1.create ? 1 : 0
  name            = var.secrets_to_create.hex_scope_management_encryption_key_1.name
  value           = random_id.hex_scope_management_encryption_key_1.hex
  content_type    = var.secrets_to_create.hex_scope_management_encryption_key_1.content_type
  key_vault_id    = var.kv_id_sensitive
  expiration_date = var.secrets_to_create.hex_scope_management_encryption_key_1.expiration_date
}

# ---
# @description Encryption key for scope management 2
# @length 32 byte hex
# @type random_id#hex
# @note Has two keys to rotate zero downtime
# ---
resource "random_id" "hex_scope_management_encryption_key_2" {
  keepers     = { version = var.secrets_to_create.hex_scope_management_encryption_key_2.rotation_counter }
  byte_length = 32
}
resource "azurerm_key_vault_secret" "hex_scope_management_encryption_key_2" {
  count           = var.secrets_to_create.hex_scope_management_encryption_key_2.create ? 1 : 0
  name            = var.secrets_to_create.hex_scope_management_encryption_key_2.name
  value           = random_id.hex_scope_management_encryption_key_2.hex
  content_type    = var.secrets_to_create.hex_scope_management_encryption_key_2.content_type
  key_vault_id    = var.kv_id_sensitive
  expiration_date = var.secrets_to_create.hex_scope_management_encryption_key_2.expiration_date
}

# ---
# @description LiteLLM master key
# @length 32 char flexible
# @type random_password
# ---
resource "random_password" "litellm_master_key" {
  keepers = { version = var.secrets_to_create.litellm_master_key.rotation_counter }
  length  = var.secrets_to_create.litellm_master_key.length
  special = var.secrets_to_create.litellm_master_key.special
}
resource "azurerm_key_vault_secret" "litellm_master_key" {
  count           = var.secrets_to_create.litellm_master_key.create ? 1 : 0
  name            = var.secrets_to_create.litellm_master_key.name
  value           = random_password.litellm_master_key.result
  content_type    = var.secrets_to_create.litellm_master_key.content_type
  key_vault_id    = var.kv_id_sensitive
  expiration_date = var.secrets_to_create.litellm_master_key.expiration_date
}

# ---
# @description LiteLLM salt key
# @length 32 char flexible
# @type random_password
# ---
resource "random_password" "litellm_salt_key" {
  keepers = { version = var.secrets_to_create.litellm_salt_key.rotation_counter }
  length  = var.secrets_to_create.litellm_salt_key.length
  special = var.secrets_to_create.litellm_salt_key.special
}
resource "azurerm_key_vault_secret" "litellm_salt_key" {
  count           = var.secrets_to_create.litellm_salt_key.create ? 1 : 0
  name            = var.secrets_to_create.litellm_salt_key.name
  value           = random_password.litellm_salt_key.result
  content_type    = var.secrets_to_create.litellm_salt_key.content_type
  key_vault_id    = var.kv_id_sensitive
  expiration_date = var.secrets_to_create.litellm_salt_key.expiration_date
}

# ---
# @description RabbitMQ password for chat
# @length 24 char flexible
# @type random_password
# ---
resource "random_password" "rabbitmq_password_chat" {
  keepers = { version = var.secrets_to_create.rabbitmq_password_chat.rotation_counter }
  length  = var.secrets_to_create.rabbitmq_password_chat.length
  special = var.secrets_to_create.rabbitmq_password_chat.special
}
resource "azurerm_key_vault_secret" "rabbitmq_password_chat" {
  count           = var.secrets_to_create.rabbitmq_password_chat.create ? 1 : 0
  name            = var.secrets_to_create.rabbitmq_password_chat.name
  value           = random_password.rabbitmq_password_chat.result
  content_type    = var.secrets_to_create.rabbitmq_password_chat.content_type
  key_vault_id    = var.kv_id_sensitive
  expiration_date = var.secrets_to_create.rabbitmq_password_chat.expiration_date
}

# ---
# @description Zitadel DB user password
# @length 32 char fix
# @type random_password
# ---
resource "random_password" "zitadel_db_user_password" {
  keepers = { version = var.secrets_to_create.zitadel_db_user_password.rotation_counter }
  length  = var.secrets_to_create.zitadel_db_user_password.length
  special = var.secrets_to_create.zitadel_db_user_password.special
}
resource "azurerm_key_vault_secret" "zitadel_db_user_password" {
  count           = var.secrets_to_create.zitadel_db_user_password.create ? 1 : 0
  name            = var.secrets_to_create.zitadel_db_user_password.name
  value           = random_password.zitadel_db_user_password.result
  content_type    = var.secrets_to_create.zitadel_db_user_password.content_type
  key_vault_id    = var.kv_id_sensitive
  expiration_date = var.secrets_to_create.zitadel_db_user_password.expiration_date
}

# ---
# @description Zitadel main key
# @length 32 char flexible
# @type random_password
# ---
resource "random_password" "zitadel_main_key" {
  keepers = { version = var.secrets_to_create.zitadel_main_key.rotation_counter }
  length  = var.secrets_to_create.zitadel_main_key.length
  special = var.secrets_to_create.zitadel_main_key.special
}
resource "azurerm_key_vault_secret" "zitadel_main_key" {
  count           = var.secrets_to_create.zitadel_main_key.create ? 1 : 0
  name            = var.secrets_to_create.zitadel_main_key.name
  value           = random_password.zitadel_main_key.result
  content_type    = var.secrets_to_create.zitadel_main_key.content_type
  key_vault_id    = var.kv_id_sensitive
  expiration_date = var.secrets_to_create.zitadel_main_key.expiration_date
}
