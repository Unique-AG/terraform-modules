variable "prometheus_node_alert_rules" {
  description = "Node level alert rules for Prometheus monitoring"
  type = list(object({
    action = optional(object({
      action_group_id = string
    }))
    alert       = optional(string)
    annotations = optional(map(string))
    enabled     = optional(bool)
    expression  = string
    for         = optional(string)
    labels      = optional(map(string))
    record      = optional(string)
    alert_resolution = optional(object({
      auto_resolved   = bool
      time_to_resolve = string
    }))
    severity = optional(number)
  }))
  default = null
}

variable "prometheus_cluster_alert_rules" {
  description = "Cluster level alert rules for Prometheus monitoring"
  type = list(object({
    action = optional(object({
      action_group_id = string
    }))
    alert       = optional(string)
    annotations = optional(map(string))
    enabled     = optional(bool)
    expression  = string
    for         = optional(string)
    labels      = optional(map(string))
    record      = optional(string)
    alert_resolution = optional(object({
      auto_resolved   = bool
      time_to_resolve = string
    }))
    severity = optional(number)
  }))
  default = null
}

variable "prometheus_pod_alert_rules" {
  description = "Pod level alert rules for Prometheus monitoring"
  type = list(object({
    action = optional(object({
      action_group_id = string
    }))
    alert       = optional(string)
    annotations = optional(map(string))
    enabled     = optional(bool)
    expression  = string
    for         = optional(string)
    labels      = optional(map(string))
    record      = optional(string)
    alert_resolution = optional(object({
      auto_resolved   = bool
      time_to_resolve = string
    }))
    severity = optional(number)
  }))
  default = null
}
