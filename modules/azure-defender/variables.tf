variable "subscription_id" {
  description = "Subscription ID"
  type        = string
}

variable "security_contact_settings" {
  type = object({
    isEnabled       = optional(bool, true)
    subscription_id = optional(string, null)
    email           = string
    phone           = optional(string, "")
    notificationsByRole = optional(object({
      state = optional(string, "On")
      roles = optional(list(string), ["Owner"])
    }), {})
    notificationsSources = optional(list(map(string)), [
      {
        sourceType       = "AttackPath"
        minimalRiskLevel = "Critical"
      },
      {
        sourceType      = "Alert"
        minimalSeverity = "High"
      }
    ])
  })
}

variable "cloud_posture_defender_settings" {
  type = object({
    tier = optional(string, "Standard")
    extensions = optional(list(object({
      name                            = string
      additional_extension_properties = optional(map(string))
    })), [])
  })
  default = {
    extensions = [
      {
        name = "ContainerRegistriesVulnerabilityAssessments"
      },
      {
        name = "AgentlessVmScanning"
        additional_extension_properties = {
          ExclusionTags = "[]"
        }
      },
      {
        name = "AgentlessDiscoveryForKubernetes"
      },
      {
        name = "SensitiveDataDiscovery"
      },
      {
        name = "EntraPermissionsManagement"
      },
      {
        name = "ApiPosture"
      }
    ]
  }
}

variable "storage_accounts_defender_settings" {
  type = object({
    tier    = optional(string, "Standard")
    subplan = optional(string, "DefenderForStorageV2")
    extensions = optional(list(object({
      name                            = string
      additional_extension_properties = optional(map(string))
    })), [])
  })
  default = {
    extensions = [
      {
        name = "OnUploadMalwareScanning"
        additional_extension_properties = {
          AutomatedResponse              = "None"
          BlobScanResultsOptions         = "BlobIndexTags"
          CapGBPerMonthPerStorageAccount = "1000"
        }
      },
      {
        name = "SensitiveDataDiscovery"
      }
    ]
  }
}

variable "virtual_machines_defender_settings" {
  type = object({
    tier    = optional(string, "Standard")
    subplan = optional(string, "P2")
    extensions = optional(list(object({
      name                            = string
      additional_extension_properties = optional(map(string))
    })), [])
  })
  default = {
    extensions = [
      {
        name = "AgentlessVmScanning"
        additional_extension_properties = {
          ExclusionTags = "[]"
        }
      }
    ]
  }
}

variable "key_vaults_defender_settings" {
  type = object({
    tier    = optional(string, "Standard")
    subplan = optional(string, "PerKeyVault")
    extensions = optional(list(object({
      name                            = string
      additional_extension_properties = optional(map(string))
    })), [])
  })
  default = {}
}

variable "arm_defender_settings" {
  type = object({
    tier    = optional(string, "Standard")
    subplan = optional(string, "PerSubscription")
    extensions = optional(list(object({
      name                            = string
      additional_extension_properties = optional(map(string))
    })), [])
  })
  default = {}
}

variable "open_source_relational_databases_defender_settings" {
  type = object({
    tier = optional(string, "Standard")
    extensions = optional(list(object({
      name                            = string
      additional_extension_properties = optional(map(string))
    })), [])
  })
  default = {}
}

variable "containers_defender_settings" {
  type = object({
    tier = optional(string, "Standard")
    extensions = optional(list(object({
      name                            = string
      additional_extension_properties = optional(map(string))
    })), [])
  })
  default = {
    extensions = [
      {
        name = "ContainerRegistriesVulnerabilityAssessments"
      },
      {
        name = "AgentlessDiscoveryForKubernetes"
      },
      {
        name = "ContainerSensor"
      },
      {
        name = "AgentlessVmScanning"
        additional_extension_properties = {
          ExclusionTags = "[]"
        }
      }
    ]
  }
}

variable "ai_defender_settings" {
  description = "Settings for Defender for AI"
  type = object({
    tier = optional(string, "Standard")
    extensions = optional(list(object({
      name                            = string
      additional_extension_properties = optional(map(string))
    })), [])
  })
  default = {}
}

variable "eventhub_export" {
  description = "Configuration for exporting Defender for Cloud data to Event Hub."
  type = object({
    name                = string
    location            = string
    resource_group_name = string
    eventhub = object({
      id                = string
      connection_string = string
    })
    sources = optional(map(object({
      event_source  = string
      property_path = optional(string, "")
      labels        = optional(list(string), [])
    })), {
      alert = {
        event_source  = "Alerts"
        property_path = "properties.metadata.severity"
        labels        = ["High", "Medium", "Low"]
      }
      assessment = {
        event_source  = "Assessments"
        property_path = "properties.status.code"
        labels        = ["Unhealthy", "Healthy"]
      }
    })
  })
  default   = null
  sensitive = true
  validation {
    condition     = var.eventhub_export == null || length(var.eventhub_export.sources) > 0
    error_message = "At least one source must be configured in the sources map."
  }
  validation {
    condition = var.eventhub_export == null || alltrue([
      for key, source in var.eventhub_export.sources :
      length(source.labels) == 0 || (length(source.labels) > 0 && source.property_path != "")
    ])
    error_message = "If labels are specified, property_path must also be provided for filtering."
  }
}
