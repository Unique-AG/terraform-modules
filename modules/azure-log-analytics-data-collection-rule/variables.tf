variable "explicit_log_analytics_destination_name" {
  description = "Log Analytics destination name when the default is not desired."
  type        = string
  default     = null
}

variable "log_analytics_workspace_id" {
  description = "ARM resource ID of the Log Analytics workspace this DCR transforms data for."
  type        = string
}

variable "name" {
  description = "Name of the Data Collection Rule."
  type        = string
}

variable "resource_group" {
  description = "Resource group where the DCR is deployed."
  type = object({
    location = string
    name     = string
  })
}

variable "tags" {
  description = "Tags applied to the DCR."
  type        = map(string)
  default     = {}
}

variable "transformations" {
  description = <<-EOT
    Raw transformKql queries keyed by Log Analytics table name.
  EOT
  type        = map(string)
  default = {
    AGWAccessLogs = <<-KQL
      source
      | extend RequestUri = iif(RequestUri contains "token=" and indexof(RequestUri, "?") >= 0, strcat(substring(RequestUri, 0, indexof(RequestUri, "?")), "?[Redacted]"), RequestUri)
      | extend RequestQuery = iif(RequestQuery contains "token=", "[Redacted]", RequestQuery)
      | extend OriginalRequestUriWithArgs = iif(OriginalRequestUriWithArgs contains "token=" and indexof(OriginalRequestUriWithArgs, "?") >= 0, strcat(substring(OriginalRequestUriWithArgs, 0, indexof(OriginalRequestUriWithArgs, "?")), "?[Redacted]"), OriginalRequestUriWithArgs)
    KQL
  }
}
