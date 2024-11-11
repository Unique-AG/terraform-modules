variable "resource_groups" {
  description = "HELLO"
  type = map(object({
    location   = string
    managed_by = optional(string, null)
    tags       = optional(map(string), {})
  }))
  default = {
    rg1 = {
      location = "eastus"
      tags = {
        environment = "dev"
      }
    }
  }
}
