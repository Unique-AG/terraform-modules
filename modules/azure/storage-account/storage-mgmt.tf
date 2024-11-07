resource "azurerm_storage_management_policy" "storage_policy" {
  count              = var.retention_period_days > 0 ? 1 : 0
  storage_account_id = azurerm_storage_account.storage_account.id

  rule {
    name    = "delete-older-than-${var.retention_period_days}-days"
    enabled = true
    filters {
      blob_types = ["blockBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_creation_greater_than = var.retention_period_days
      }
      snapshot {
        delete_after_days_since_creation_greater_than = var.retention_period_days
      }
      version {
        delete_after_days_since_creation = var.retention_period_days
      }
    }
  }
}