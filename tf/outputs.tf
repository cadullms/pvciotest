output "cluster_resource_group_name" {
    value = azurerm_kubernetes_cluster.aks.resource_group_name
}

output "cluster_name" {
    value = azurerm_kubernetes_cluster.aks.name
}

output "storage_account_name" {
    value = azurerm_storage_account.storage.name
}

output "storage_account_resource_group_name" {
    value = azurerm_storage_account.storage.resource_group_name
}