terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

resource "azurerm_key_vault" "core" {
  name                = "core-kv"
  location            = "world"
  resource_group_name = "rg"
  tenant_id           = "00000000-0000-0000-0000-000000000000"
  sku_name            = "standard"
  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
  }
}

resource "azurerm_key_vault" "sensitive" {
  name                = "sensitive-kv"
  location            = "world"
  resource_group_name = "rg"
  tenant_id           = "00000000-0000-0000-0000-000000000000"
  sku_name            = "standard"
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
