locals {
  create_vault_secrets = var.key_vault_id != null
  password_secret_name = var.password_secret_name == null ? "${var.name}-password" : var.password_secret_name
  host_secret_name     = var.host_secret_name == null ? "${var.name}-host" : var.host_secret_name
  port_secret_name     = var.port_secret_name == null ? "${var.name}-port" : var.port_secret_name
}

resource "azurerm_key_vault_secret" "redis-cache-password" {
  count        = local.create_vault_secrets ? 1 : 0
  name         = local.password_secret_name
  value        = azurerm_redis_cache.arc.primary_access_key
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "redis-cache-host-dns" {
  count        = local.create_vault_secrets ? 1 : 0
  name         = local.host_secret_name
  value        = azurerm_redis_cache.arc.hostname
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "redis-cache-host-dns" {
  count        = local.create_vault_secrets ? 1 : 0
  name         = local.port_secret_name
  value        = azurerm_redis_cache.arc.ssl_port
  key_vault_id = var.key_vault_id
}
