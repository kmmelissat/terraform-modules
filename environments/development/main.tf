terraform {
  required_version = ">= 1.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
}

locals {
  common_tags = merge(
    {
      application = var.application_name
      environment = var.environment
      managed_by  = "terraform"
    },
    var.additional_tags
  )
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

module "network" {
  source = "../../modules/network"

  name                = "vnet-orders-dev"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.10.0.0/16"]

  subnets = {
    application = {
      name             = "snet-application"
      address_prefixes = ["10.10.1.0/24"]
    }
    data = {
      name             = "snet-data"
      address_prefixes = ["10.10.2.0/24"]
    }
  }

  tags = local.common_tags
}

moved {
  from = azurerm_virtual_network.main
  to   = module.network.azurerm_virtual_network.main
}

moved {
  from = azurerm_subnet.application
  to   = module.network.azurerm_subnet.main["application"]
}

moved {
  from = azurerm_subnet.data
  to   = module.network.azurerm_subnet.main["data"]
}
