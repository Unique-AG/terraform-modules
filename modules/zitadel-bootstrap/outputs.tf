output "root_org_id" {
  description = "ID of the Helm-created root organization."
  value       = local.root_org_id
}

output "project_id" {
  description = "ID of the Unique Apps project."
  value       = zitadel_project.unique_apps.id
}

output "client_id" {
  description = "Client ID of the Standalone Apps PKCE application."
  value       = zitadel_application_oidc.standalone_apps.client_id
  sensitive   = true
}

output "target_org_id" {
  description = "ID of the tenant organization."
  value       = zitadel_org.target.id
}

output "scope_management_user_id" {
  description = "ID of the node-scope-management JWT machine user."
  value       = zitadel_machine_user.scope_management.id
}

output "scope_management_pat" {
  description = "PAT of the node-scope-management machine user."
  value       = zitadel_personal_access_token.scope_management.token
  sensitive   = true
}

output "human_user_ids" {
  description = "IDs of the created human users, keyed by user name."
  value       = { for name, user in zitadel_human_user.this : name => user.id }
}
