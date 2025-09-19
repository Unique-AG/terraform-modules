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
          CapGBPerMonthPerStorageAccount = "1000"
          BlobScanResultsOptions         = "BlobIndexTags"
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
