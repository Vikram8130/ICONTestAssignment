# Terraform Block
terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
  #Terraform State Storage Account
  backend "azurerm" {}
}

# Providers Block
provider "azurerm" {
  features {}
}

# Random String Resource

resource "random_string" "myrandom" {
  length  = 6
  number  = false
  upper   = false
  special = false
}