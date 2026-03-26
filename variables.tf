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
