terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

resource "azurerm_key_vault" "core" {
  location                   = "world"
  name                       = "core-kv"
  rbac_authorization_enabled = true
  resource_group_name        = "rg"
  tenant_id                  = "00000000-0000-0000-0000-000000000000"

  sku_name = "standard"
  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
  }
}

resource "azurerm_key_vault" "sensitive" {
  location                   = "world"
  name                       = "sensitive-kv"
  rbac_authorization_enabled = true
  resource_group_name        = "rg"
  sku_name                   = "standard"
  tenant_id                  = "00000000-0000-0000-0000-000000000000"
  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
  }
}

module "secrets_bundle" {
  source          = "../.."
  kv_id_core      = azurerm_key_vault.core.id
  kv_id_sensitive = azurerm_key_vault.sensitive.id
}
