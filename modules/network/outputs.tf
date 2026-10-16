output "vnet_id" {
  description = "ID de la red virtual"
  value       = azurerm_virtual_network.main.id
}

output "subnet_ids" {
  description = "IDs de las subnets por clave lógica"
  value       = { for key, s in azurerm_subnet.main : key => s.id }
}
