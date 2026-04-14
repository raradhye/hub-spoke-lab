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
variable "environment_name" {
  description = "environment name (dev or prod)"
  type        = string
}
variable "hub_vm_id" {
  description = "Hub VM Resource ID"
  type        = string
}
variable "spoke_vm_id" {
  description = "Spoke VM Resource ID"
  type        = string
}
variable "alert_email" {
  description = "Email address for alert notification"
  type        = string
}
