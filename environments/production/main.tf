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

  name                = "vnet-orders-prod"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.20.0.0/16"]

  subnets = {
    application = {
      name             = "snet-application"
      address_prefixes = ["10.20.1.0/24"]
    }
    data = {
      name             = "snet-data"
      address_prefixes = ["10.20.2.0/24"]
    }
  }

  tags = local.common_tags
}

