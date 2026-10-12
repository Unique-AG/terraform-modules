variable "root_org_name" {
  description = "Exact name of the organization created by the ZITADEL Helm chart (FirstInstance.Org.Name) that owns the Unique Apps project."
  type        = string
  default     = "Cluster IAM"
}

variable "target_org_name" {
  description = "Exact name of the tenant organization that receives the Unique Apps project grant."
  type        = string

  validation {
    condition     = length(trimspace(var.target_org_name)) > 0
    error_message = "target_org_name must not be empty."
  }
}

variable "project_roles" {
  description = "Role keys of the Unique Apps project; all of them are granted to the target organization."
  type        = set(string)
  default = [
    "chat.chat.basic",
    "chat.chat.unlimited",
    "chat.knowledge.read",
    "chat.knowledge.write",
    "chat.feedback.read",
    "chat.admin.all",
    "chat.data.admin",
    "chat.debug.read",
    "admin.user-management.write",
    "admin.space.write",
    "admin.app-repository.write",
    "connector.admin.read",
    "connector.admin.write",
  ]
}

variable "oidc_dev_mode" {
  description = "Enable OIDC development mode on the Standalone Apps application. Required for plain-HTTP redirect URIs."
  type        = bool
  default     = false
}

variable "frontend_base_url" {
  description = "Unique frontend origin; the default redirect URI set appends the deployed frontend paths (/chat, /admin, /knowledge-upload, /theme)."
  type        = string

  validation {
    condition     = can(regex("^https?://[^/]+/?$", var.frontend_base_url))
    error_message = "frontend_base_url must be an http(s) origin without a path."
  }
}

variable "redirect_uris" {
  description = "Exact redirect URI override list. An empty list derives the frontend paths from frontend_base_url."
  type        = list(string)
  default     = []
}

variable "post_logout_redirect_uris" {
  description = "Exact post-logout URI override list. An empty list derives the frontend paths from frontend_base_url."
  type        = list(string)
  default     = []
}

variable "scope_management_user_name" {
  description = "Username of the JWT machine user used by node-scope-management."
  type        = string
  default     = "scope-management"

  validation {
    condition     = length(trimspace(var.scope_management_user_name)) > 0
    error_message = "scope_management_user_name must not be empty."
  }
}

variable "scope_management_pat_expiration_date" {
  description = "RFC3339 expiration of the node-scope-management PAT. An explicit value avoids perpetual replacement after ZITADEL normalizes an omitted one."
  type        = string
  default     = "9999-12-31T23:59:59Z"
}

variable "human_users" {
  description = "Human users created in the target organization, keyed by user name, with the project roles granted to each. Intended for development and trial environments."
  type = map(object({
    first_name = string
    last_name  = string
    email      = string
    roles      = set(string)
  }))
  default = {}
}

variable "human_users_initial_password" {
  description = "Initial password of every user in human_users. Required when human_users is not empty."
  type        = string
  sensitive   = true
  default     = null
}
