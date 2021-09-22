resource "azurerm_role_assignment" "make_aks_storage_contributor" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_id.principal_id
}

resource "azurerm_role_assignment" "make_aks_kubelet_id_storage_contributor" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_kubelet_id.principal_id
}

resource "azurerm_role_assignment" "make_aks_kubelet_id_contributor" {
  scope                = azurerm_user_assigned_identity.aks_kubelet_id.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_id.principal_id
}

resource "azurerm_role_assignment" "make_aks_vnet_contributor" {
  scope                = azurerm_virtual_network.vnet.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_id.principal_id
}

resource "azurerm_role_assignment" "make_aks_kubelet_id_vnet_contributor" {
  scope                = azurerm_virtual_network.vnet.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_kubelet_id.principal_id
}

resource "azurerm_role_assignment" "make_aks_kubelet_id_node_rg_contributor" {
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourcegroups/${azurerm_kubernetes_cluster.aks.node_resource_group}"
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_kubelet_id.principal_id
}

