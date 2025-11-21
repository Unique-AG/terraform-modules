output "client_id" {
  description = "The client ID of the underlying Azure Entra App Registration."
  value       = azuread_application.sp_for_rbac.client_id
}

output "object_id" {
  description = "The object ID of the matching Service Principal to be used for effective role assignments."
  value       = azuread_service_principal.sp_for_rbac.object_id
}
