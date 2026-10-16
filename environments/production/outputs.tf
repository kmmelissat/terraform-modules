output "vnet_id" {
  description = "ID de la red virtual"
  value       = module.network.vnet_id
}

output "application_subnet_id" {
  description = "ID de la subnet de aplicación"
  value       = module.network.subnet_ids["application"]
}
