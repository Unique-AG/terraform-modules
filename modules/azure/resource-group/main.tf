resource "azurerm_resource_group" "this" {
  for_each = length(var.resource_groups) > 0 ? var.resource_groups : {}

  name       = each.key
  location   = each.value.location
  managed_by = each.value.managed_by
  tags       = each.value.tags
}
