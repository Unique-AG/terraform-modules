locals {
  uses_cmk = var.customer_managed_key != null && var.self_cmk == null
  self_cmk = var.self_cmk != null && var.customer_managed_key == null
}

resource "azurerm_postgresql_flexible_server" "apfs" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  version             = var.flex_pg_version

  administrator_login    = var.administrator_login
  administrator_password = var.admin_password
  sku_name               = var.flex_sku
  storage_mb             = var.flex_storage_mb
  tags                   = var.tags
  zone                   = var.zone

  public_network_access_enabled = var.public_network_access_enabled
  backup_retention_days         = var.flex_pg_backup_retention_days

  delegated_subnet_id = var.delegated_subnet_id
  private_dns_zone_id = var.private_dns_zone_id

  dynamic "customer_managed_key" {
    for_each = local.self_cmk ? [1] : []
    content {
      key_vault_key_id                  = azurerm_key_vault_key.psql-account-byok[0].id
      primary_user_assigned_identity_id = var.self_cmk.user_assigned_identity_id
    }
  }

  dynamic "customer_managed_key" {
    for_each = local.uses_cmk ? [1] : []
    content {
      key_vault_key_id                  = var.customer_managed_key.key_vault_key_id
      primary_user_assigned_identity_id = var.customer_managed_key.user_assigned_identity_id
    }
  }

  identity {
    type         = length(var.identity_ids) > 0 ? "SystemAssigned, UserAssigned" : "SystemAssigned"
    identity_ids = var.identity_ids
  }

  dynamic "timeouts" {
    for_each = length(var.timeouts) > 0 ? [1] : []
    content {
      create = var.timeouts.create
      read   = var.timeouts.read
      update = var.timeouts.update
      delete = var.timeouts.delete
    }
  }
}

resource "azurerm_postgresql_flexible_server_configuration" "parameters" {
  for_each  = var.parameter_values
  server_id = azurerm_postgresql_flexible_server.apfs.id
  name      = each.key
  value     = each.value
}

resource "azurerm_postgresql_flexible_server_database" "indestructible_database_server" {
  for_each = { for key, val in var.databases :
  key => val if val.prevent_destroy }
  name      = each.value.name
  server_id = azurerm_postgresql_flexible_server.apfs.id
  collation = each.value.collation
  charset   = each.value.charset
  lifecycle {
    prevent_destroy = "true"
  }
}

resource "azurerm_postgresql_flexible_server_database" "destructible_database_server" {
  for_each = { for key, val in var.databases :
  key => val if !val.prevent_destroy }
  name      = each.value.name
  server_id = azurerm_postgresql_flexible_server.apfs.id
  collation = each.value.collation
  charset   = each.value.charset
  lifecycle {
    prevent_destroy = "false"
  }
}

resource "azurerm_key_vault_key" "psql-account-byok" {
  count        = local.self_cmk ? 1 : 0
  name         = var.self_cmk.key_name
  key_vault_id = var.self_cmk.key_vault_id
  key_type     = var.self_cmk.key_type
  key_size     = var.self_cmk.key_size
  key_opts     = var.self_cmk.key_opts
}
