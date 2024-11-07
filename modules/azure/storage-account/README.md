
# Module: st

This Terraform module creates a secure and well-configured Azure storage account. It sets up basic storage settings, enforces HTTPS traffic, and allows you to define CORS rules for web applications. The use of a managed identity provides a secure way to grant access to other Azure services.

## Usage

To use this module, include the following code in your Terraform configuration:

module "st" {
  source               = "./modules/st"
  storage_account_name = "storage${var.subscription_purpose}${var.environment}"
  resource_group_name  = data.azurerm_resource_group.sensitive.name
  location             = data.azurerm_resource_group.sensitive.location
  tags                 = local.tags
  key_vault_id         = data.azurerm_key_vault.sensitive-kv.id
}