variable "resource_groups" {
  type = map(object({
    location   = string
    managed_by = optional(string)
    tags       = map(string)
  }))
  default = {
    rg1 = {
      location = "eastus"
      tags = {
        environment = "dev"
      }
    }
    rg2 = {
      location = "westus"
      tags = {
        environment = "prod"
      }
    }
  }
}
