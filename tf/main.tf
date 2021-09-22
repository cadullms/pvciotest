data "azurerm_subscription" "current" {
}

resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location
}

resource "azurerm_log_analytics_workspace" "laws" {
  name                = local.laws_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

data "azurerm_kubernetes_service_versions" "current" {
  location       = azurerm_resource_group.rg.location
  version_prefix = var.kubernetes_version_prefix
}

resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_storage_account" "storage" {
  name                     = local.storage_account_name
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
  nfsv3_enabled            = true
  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.aks_subnet.id]
  }
}

# Don't know yet whether we need this. Does not work directly currently.
# See the following issue for a workaround, in case we need to precreate this: https://github.com/hashicorp/terraform-provider-azurerm/issues/2977
# resource "azurerm_storage_container" "storage_container" {
#   name                  = var.nfs_container_name
#   storage_account_name  = azurerm_storage_account.storage.name
#   container_access_type = "private"
# }

resource "azurerm_user_assigned_identity" "aks_id" {
  name                = local.aks_id_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_user_assigned_identity" "aks_kubelet_id" {
  name                = local.aks_kubelet_id_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = local.aks_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = local.aks_name
  kubernetes_version  = data.azurerm_kubernetes_service_versions.current.latest_version

  default_node_pool {
    name       = var.default_node_pool_name
    node_count = var.node_count
    vm_size    = var.machine_size
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  identity {
    type                      = "UserAssigned"
    user_assigned_identity_id = azurerm_user_assigned_identity.aks_id.id
  }

  kubelet_identity {
    user_assigned_identity_id = azurerm_user_assigned_identity.aks_kubelet_id.id
    client_id = azurerm_user_assigned_identity.aks_kubelet_id.client_id
    object_id = azurerm_user_assigned_identity.aks_kubelet_id.principal_id
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.laws.id
    }
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "Standard"
    service_cidr = "10.1.0.0/20"
    dns_service_ip = "10.1.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  depends_on = [
    azurerm_role_assignment.make_aks_storage_contributor,
    azurerm_role_assignment.make_aks_vnet_contributor,
    azurerm_role_assignment.make_aks_kubelet_id_contributor
  ]
}
