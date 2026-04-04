output "hub_vm_private_ip" {
  description = "Hub VM Private IP"
  value       = azurerm_linux_virtual_machine.hub_vm.private_ip_address
}
output "spoke_vm_private_ip" {
  description = "Spoke VM Private IP"
  value       = azurerm_linux_virtual_machine.spoke_vm.private_ip_address
}
