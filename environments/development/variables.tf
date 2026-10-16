variable "subscription_id" {
  description = "ID de la suscripción de Azure"
  type        = string
}

variable "location" {
  description = "Región utilizada por los recursos"
  type        = string
}

variable "resource_group_name" {
  description = "Nombre del Resource Group principal"
  type        = string
}

variable "application_name" {
  description = "Nombre de la aplicación"
  type        = string
}

variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
  default     = "development"

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "environment debe ser development, staging o production."
  }
}

variable "additional_tags" {
  description = "Tags adicionales"
  type        = map(string)
  default     = {}
}
