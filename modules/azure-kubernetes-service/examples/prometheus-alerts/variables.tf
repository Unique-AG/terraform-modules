# Variables for alert configuration
variable "alert_configuration" {
  description = "Configuration for AKS alerts and monitoring"
  type = object({
    email_receiver = optional(object({
      email_address = string
      name          = optional(string, "aks-alerts-email")
    }), null)
    action_group = optional(object({
      short_name = optional(string, "aks-alerts")
      location   = optional(string, "westeurope")
    }), null)
  })
  default = null
}

# Prometheus alert rule variables
variable "prometheus_node_alert_rules" {
  description = "Node level Prometheus alert rules"
  type = list(object({
    alert      = string
    enabled    = bool
    expression = string
    for        = optional(string)
    severity   = number
    action = optional(object({
      action_group_id = string
    }))
    alert_resolution = optional(object({
      auto_resolved   = bool
      time_to_resolve = string
    }))
    annotations = optional(map(string))
    labels      = optional(map(string))
  }))
  default = null
}

variable "prometheus_cluster_alert_rules" {
  description = "Cluster level Prometheus alert rules"
  type = list(object({
    alert      = string
    enabled    = bool
    expression = string
    for        = optional(string)
    severity   = number
    action = optional(object({
      action_group_id = string
    }))
    alert_resolution = optional(object({
      auto_resolved   = bool
      time_to_resolve = string
    }))
    annotations = optional(map(string))
    labels      = optional(map(string))
  }))
  default = null
}

variable "prometheus_pod_alert_rules" {
  description = "Pod level Prometheus alert rules"
  type = list(object({
    alert      = string
    enabled    = bool
    expression = string
    for        = optional(string)
    severity   = number
    action = optional(object({
      action_group_id = string
    }))
    alert_resolution = optional(object({
      auto_resolved   = bool
      time_to_resolve = string
    }))
    annotations = optional(map(string))
    labels      = optional(map(string))
  }))
  default = null
}

# Prometheus recording rule variables
variable "prometheus_node_recording_rules" {
  description = "Node level recording rules for Prometheus monitoring"
  type = list(object({
    enabled    = optional(bool, true)
    record     = string
    expression = string
    labels     = optional(map(string))
  }))
  default = null
}

variable "prometheus_kubernetes_recording_rules" {
  description = "Kubernetes level recording rules for Prometheus monitoring"
  type = list(object({
    enabled    = optional(bool, true)
    record     = string
    expression = string
    labels     = optional(map(string))
  }))
  default = null
}

variable "prometheus_ux_recording_rules" {
  description = "UX level recording rules for Prometheus monitoring"
  type = list(object({
    enabled    = optional(bool, true)
    record     = string
    expression = string
    labels     = optional(map(string))
  }))
  default = null
}

variable "subscription_id" {
  description = "Subscription ID"
  type        = string
}
