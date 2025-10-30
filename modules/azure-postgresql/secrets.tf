locals {
  create_vault_secrets = var.key_vault_id != null
  host_secret_name     = var.host_secret_name == null ? "${var.name}-host" : var.host_secret_name
  port_secret_name     = var.port_secret_name == null ? "${var.name}-port" : var.port_secret_name
  username_secret_name = var.username_secret_name == null ? "${var.name}-username" : var.username_secret_name
  password_secret_name = var.password_secret_name == null ? "${var.name}-password" : var.password_secret_name
}

resource "azurerm_key_vault_secret" "host" {
  count = local.create_vault_secrets ? 1 : 0

  content_type    = "text/plain"
  expiration_date = "2099-12-31T23:59:59Z"
  key_vault_id    = var.key_vault_id
  name            = local.host_secret_name
  tags            = var.secrets_tags
  value           = azurerm_postgresql_flexible_server.apfs.fqdn
}

resource "azurerm_key_vault_secret" "port" {
  count = local.create_vault_secrets ? 1 : 0

  content_type    = "text/plain"
  expiration_date = "2099-12-31T23:59:59Z"
  key_vault_id    = var.key_vault_id
  name            = local.port_secret_name
  tags            = var.secrets_tags
  value           = "5432"
}

resource "azurerm_key_vault_secret" "username" {
  count = local.create_vault_secrets ? 1 : 0

  content_type    = "text/plain"
  expiration_date = "2099-12-31T23:59:59Z"
  key_vault_id    = var.key_vault_id
  name            = local.username_secret_name
  tags            = var.secrets_tags
  value           = var.administrator_login
}

resource "azurerm_key_vault_secret" "password" {
  count = local.create_vault_secrets ? 1 : 0

  content_type    = "text/plain"
  expiration_date = "2099-12-31T23:59:59Z"
  key_vault_id    = var.key_vault_id
  name            = local.password_secret_name
  tags            = var.secrets_tags
  value           = var.admin_password
}

resource "azurerm_key_vault_secret" "database_connection_strings" {
  for_each = local.create_vault_secrets ? var.databases : {}

  content_type    = "text/plain"
  expiration_date = "2099-12-31T23:59:59Z"
  key_vault_id    = var.key_vault_id
  name            = "${var.database_connection_string_secret_prefix}${each.value.name}"
  tags            = var.secrets_tags
  value           = "postgresql://${var.administrator_login}:${var.admin_password}@${azurerm_postgresql_flexible_server.apfs.fqdn}/${each.value.name}"
}
