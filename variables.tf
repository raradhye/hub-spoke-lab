variable "location" {
  description = "Azure region for all the resources"
  type        = string
  default     = "westus"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-hub-spoke-lab"
}
variable "admin_username" {
  description = "VM admin username"
  type        = string
  default     = "adminuser"
}
variable "admin_password" {
  description = "VM admin password"
  type        = string
  sensitive   = true
}
variable "environment_name" {
  description = "environment name (dev or prod)"
  type        = string
}
variable "spoke_vnet_address" {
  description = "Spoke VNet address space"
  type        = string
}
variable "spoke_vnet_subnet" {
  description = "Spoke app subnet address space"
  type        = string
}
