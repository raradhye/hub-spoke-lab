output "hub_vnet_id" {
  description = "Hub VNet ID"
  value       = module.networking.hub_vnet_id
}
output "spoke_vnet_id" {
  description = "Spoke VNet Id"
  value       = module.networking.spoke_vnet_id
}
output "hub_vm_private_ip" {
  description = "Hub VM Private IP"
  value       = module.vm.hub_vm_private_ip
}
output "spoke_vm_private_ip" {
  description = "Spoke VM Private IP"
  value       = module.vm.spoke_vm_private_ip
}
output "key_vault_id" {
  description = "Key vault resource ID"
  value       = module.keyvault.key_vault_id
}
