output "kubernetes_cluster_id" {
  description = "The ID of the Kubernetes cluster."
  value       = azurerm_kubernetes_cluster.cluster.id
}

output "kubernetes_node_rg_name" {
  description = "The name of the node resource group. This name is important as the CSI driver identity is created there."
  value       = azurerm_kubernetes_cluster.cluster.node_resource_group
}

output "csi_user_assigned_identity_name" {
  description = "The name of the user-assigned identity for the CSI driver. Prefer using the csi_identity_client_id and csi_identity_object_id outputs as they are more reliable."
  value       = "azurekeyvaultsecretsprovider-${azurerm_kubernetes_cluster.cluster.name}"
}

output "kublet_identity_client_id" {
  description = "The client ID of the identity used by the kubelet."
  value       = azurerm_kubernetes_cluster.cluster.kubelet_identity[0].client_id
}

output "kublet_identity_object_id" {
  description = "The object ID of the identity used by the kubelet."
  value       = azurerm_kubernetes_cluster.cluster.kubelet_identity[0].object_id
}

output "agic_identity_client_id" {
  description = "The client ID of the identity used by the Application Gateway Ingress Controller."
  value       = azurerm_kubernetes_cluster.cluster.ingress_application_gateway[0].ingress_application_gateway_identity[0].client_id
}

output "agic_identity_object_id" {
  description = "The object ID of the identity used by the Application Gateway Ingress Controller."
  value       = azurerm_kubernetes_cluster.cluster.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}

output "csi_identity_client_id" {
  description = "The client ID of the identity used by the CSI driver."
  value       = azurerm_kubernetes_cluster.cluster.key_vault_secrets_provider[0].secret_identity[0].client_id
}

output "csi_identity_object_id" {
  description = "The object ID of the identity used by the CSI driver."
  value       = azurerm_kubernetes_cluster.cluster.key_vault_secrets_provider[0].secret_identity[0].object_id
}

output "cluster_resource" {
  description = "The properties of the Kubernetes cluster."
  value       = azurerm_kubernetes_cluster.cluster
}
