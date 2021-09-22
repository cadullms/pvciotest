variable "name_prefix" {
  type    = string
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "kubernetes_version_prefix" {
  type    = string
  default = "1.21"
}

variable "nfs_container_name" {
  type = string
  default = "nfsvol"
}

variable "file_share_name" {
  type = string
  default = "fileshare"
}

variable "machine_size" {
  type = string
  default = "Standard_D2_v2"
}

variable "node_count" {
  type = number
  default = 1
}

variable "default_node_pool_name" {
  type = string
  default = "default"
}