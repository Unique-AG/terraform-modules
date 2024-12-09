terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
resource "random_password" "postgres_username" {
  length  = 16
  special = false
}

resource "random_password" "postgres_password" {
  length  = 32
  special = false
}
module "apfs" {
  source              = "../.."
  admin_password      = random_password.postgres_password.result
  administrator_login = random_password.postgres_username.result
  name                = "my-postgresql-server"
  resource_group_name = "my-resource-group"
  location            = "switzerlandnorth"
  tags = {
    environment = "example"
  }
}
