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
variable "environment_name" {
  description = "environment name (dev or prod)"
  type        = string
}
variable "hub_subnet_id" {
  description = "Hub shared subnet ID for hub VM"
  type        = string
}
variable "spoke_subnet_id" {
  description = "Spoke app subnet ID for spoke VM"
  type        = string
}
variable "key_vault_id" {
  description = "Key Vault ID to read admin password from"
  type        = string
}
