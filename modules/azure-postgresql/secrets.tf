locals {
  create_vault_secrets = var.key_vault_id != null
  host_secret_name     = var.host_secret_name == null ? "${var.name}-host" : var.host_secret_name
  port_secret_name     = var.port_secret_name == null ? "${var.name}-port" : var.port_secret_name
  username_secret_name = var.username_secret_name == null ? "${var.name}-username" : var.username_secret_name
  password_secret_name = var.password_secret_name == null ? "${var.name}-password" : var.password_secret_name
}

resource "azurerm_key_vault_secret" "host" {
  count        = local.create_vault_secrets ? 1 : 0
  name         = local.host_secret_name
  value        = azurerm_postgresql_flexible_server.apfs.fqdn
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "port" {
  count        = local.create_vault_secrets ? 1 : 0
  name         = local.port_secret_name
  value        = "5432"
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "username" {
  count        = local.create_vault_secrets ? 1 : 0
  name         = local.username_secret_name
  value        = var.administrator_login
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "password" {
  count        = local.create_vault_secrets ? 1 : 0
  name         = local.password_secret_name
  value        = var.admin_password
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "database_connection_strings" {
  for_each     = local.create_vault_secrets ? var.databases : {}
  name         = "${var.database_connection_string_secret_prefix}${each.value.name}"
  value        = "postgresql://${var.administrator_login}:${var.admin_password}@${azurerm_postgresql_flexible_server.apfs.fqdn}/${each.value.name}"
  key_vault_id = var.key_vault_id
}