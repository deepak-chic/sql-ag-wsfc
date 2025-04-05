variable "project_name" {
  type    = string
  default = ""
}

variable "primary_location_name" {
  type    = string
  default = ""
}

variable "secondry_location_name" {
  type    = string
  default = ""
}

variable "environment_name" {
  type    = string
  default = ""
}

variable "primary_resource_group_name" {
  type    = string
  default = ""
}

variable "secondry_resource_group_name" {
  type    = string
  default = ""
}

variable "primary_vnet_name" {
  type    = string
  default = ""
}

variable "secondry_vnet_name" {
  type    = string
  default = ""
}

variable "primary_vnet_peering_name" {
  type    = string
  default = ""
}

variable "secondry_vnet_peering_name" {
  type    = string
  default = ""
}

variable "primary_nsg_name" {
  type    = string
  default = ""
}

variable "secondry_nsg_name" {
  type    = string
  default = ""  
}

variable "primary_sql_server_vm_name" {
  type    = string
  default = ""
}

variable "primary_sql_server_vm_nic_name" {
  type    = string
  default = ""
}

variable "primary_sql_server_vm_public_ip_name" {
  type    = string
  default = ""  
}

variable "secondry_sql_server_vm_name" {
  type    = string
  default = ""
}

variable "secondry_sql_server_vm_nic_name" {
  type    = string
  default = ""
}

variable "secondry_sql_server_vm_public_ip_name" {
  type    = string
  default = ""  
}

variable "application_vm_name" {
  type    = string
  default = ""
}

variable "application_vm_nic_name" {
  type    = string
  default = ""
}

variable "application_vm_public_ip_name" {
  type    = string
  default = ""  
}

variable "domaincontroller_vm_name" {
  type    = string
  default = ""
}

variable "domaincontroller_vm_nic_name" {
  type    = string
  default = ""
}

variable "domaincontroller_vm_public_ip_name" {
  type    = string
  default = ""  
}