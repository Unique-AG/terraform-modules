terraform {
  required_version = ">= 1.5"
  required_providers {
    zitadel = {
      source = "zitadel/zitadel"
      # 3.4.0 still speaks the legacy APIs that ZITADEL 3.x serves.
      version = "= 3.4.0"
    }
  }
}
