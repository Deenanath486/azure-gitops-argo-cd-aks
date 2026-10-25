output "resource_group_name" {
  description = "The Resource Group name"
  value       = azurerm_resource_group.rg.name
}

output "aks_cluster_name" {
  description = "Name of the provisioned AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_oidc_issuer_url" {
  description = "OIDC Issuer URL used for Azure Workload Identity with ArgoCD"
  value       = azurerm_kubernetes_cluster.aks.oidc_issuer_url
}

output "key_vault_name" {
  description = "Key Vault name used for storing GitOps secrets"
  value       = azurerm_key_vault.kv.name
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = azurerm_key_vault.kv.vault_uri
}

output "azure_cli_credentials_command" {
  description = "Azure CLI command to obtain kubeconfig credentials"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.rg.name} --name ${azurerm_kubernetes_cluster.aks.name} --overwrite-existing"
}
