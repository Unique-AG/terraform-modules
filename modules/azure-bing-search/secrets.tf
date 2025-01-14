locals {
  create_vault_secrets = var.key_vault_id != null
}

resource "azurerm_key_vault_secret" "bing_api_url" {
  count        = local.create_vault_secrets ? 1 : 0
  name         = var.secret_name_bing_search_api_url
  value        = jsondecode(azurerm_resource_group_template_deployment.argtd_bing_search_v7.output_content).endpoint.value
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "bing_subscription_key_1" {
  count        = local.create_vault_secrets ? 1 : 0
  name         = "${var.secret_name_bing_search_subscription_key}-1"
  value        = jsondecode(azurerm_resource_group_template_deployment.argtd_bing_search_v7.output_content).accessKeys.value.key1
  key_vault_id = var.key_vault_id
}
resource "azurerm_key_vault_secret" "bing_subscription_key_2" {
  count        = local.create_vault_secrets ? 1 : 0
  name         = "${var.secret_name_bing_search_subscription_key}-2"
  value        = jsondecode(azurerm_resource_group_template_deployment.argtd_bing_search_v7.output_content).accessKeys.value.key1
  key_vault_id = var.key_vault_id
}
