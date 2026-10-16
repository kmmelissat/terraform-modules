variable "name" {
  description = "Nombre de la red virtual"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group donde se crea la red"
  type        = string
}

variable "location" {
  description = "Región de la red"
  type        = string
}

variable "address_space" {
  description = "Rangos CIDR de la red virtual"
  type        = list(string)
}

variable "subnets" {
  description = "Subnets por clave lógica"
  type = map(object({
    name             = string
    address_prefixes = list(string)
  }))
}

variable "tags" {
  description = "Tags de los recursos"
  type        = map(string)
  default     = {}
}
