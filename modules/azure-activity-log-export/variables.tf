variable "name" {
  description = "Name of the diagnostic setting for Activity Log export."
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID whose Activity Log will be exported."
  type        = string
}

variable "eventhub" {
  description = "Event Hub configuration for Activity Log export."
  type = object({
    name                    = string
    resource_group_name     = string
    namespace_name          = string
    authorization_rule_name = string
  })
  nullable = false
}

variable "categories" {
  description = "List of Activity Log categories to export."
  type        = list(string)
  default = [
    "Administrative",
    "Security",
    "ServiceHealth",
    "Alert",
    "Recommendation",
    "Policy",
    "Autoscale",
    "ResourceHealth"
  ]
}
