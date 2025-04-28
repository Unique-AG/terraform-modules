locals {
  manual_secrets = merge(var.default_secrets_placeholders, var.extra_secrets_placeholders)
}

resource "azurerm_key_vault_secret" "manual_secret" {
  for_each        = local.manual_secrets
  name            = "manual-${each.key}"
  value           = "<TO BE SET MANUALLY>"
  key_vault_id    = var.kv_id_core
  expiration_date = lookup(each.value, "expiration_date", "2099-12-31T23:59:59Z")
  content_type    = lookup(each.value, "content_type", "text/plain")
  lifecycle {
    ignore_changes = [value, tags]
  }
}
