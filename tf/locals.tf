locals {
  rg_name = "${var.name_prefix}rg"
  laws_name = "${var.name_prefix}laws"
  vnet_name = "${var.name_prefix}vnet"
  aks_id_name = "${var.name_prefix}aksmi"
  aks_kubelet_id_name = "${var.name_prefix}akskubeletmi"
  aks_name = "${var.name_prefix}aks"
  storage_account_name = "${var.name_prefix}stor"
  nfs_container_name = "nfsvol"
}