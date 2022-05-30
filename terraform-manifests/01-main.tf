# We will define 
# 1. Terraform Settings Block
# 1. Required Version Terraform
# 2. Required Terraform Providers
# 3. Terraform Remote State Storage with Azure Storage Account (last step of this section)
# 2. Terraform Provider Block for AzureRM
# 3. Terraform Resource Block: Define a Random Pet Resource

# 1. Terraform Settings Block
terraform {
  # 1. Required Version Terraform
  required_version = ">= 0.13"
  # 2. Required Terraform Providers  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

# Terraform State Storage to Azure Storage Container
  backend "azurerm" {
    resource_group_name   = "terraform-storage-rg"
    storage_account_name  = "terraformstatexlrwdrzs"
    container_name        = "tfstatefiles"
    key                   = "terraform-custom-vnet.tfstate"
  }  
}

/*
Terraform supports a number of different methods for authenticating to Azure:

Authenticating to Azure using the Azure CLI
Authenticating to Azure using Managed Service Identity
Authenticating to Azure using a Service Principal and a Client Certificate
Authenticating to Azure using a Service Principal and a Client Secret
# We first specify the terraform provider. 
# Terraform will use the provider to ensure that we can work with Microsoft Azure

**** It is being recommended to use either a Service Principal or System Assigned Managed Identity when running Terraform non-interactively 
(such as when running Terraform in a CI server) - and authenticating using the Azure CLI when running Terraform locally.

Here we need to mention the Azure AD Application Object credentials to allow us to work with our Azure account. 
Application Object(credentials) is a form of identity in Azure AD whose details can be easily embedded in our terraform 
configuartion file which can be used for authentication and authorization
*/

provider "azurerm" {
  subscription_id = "6912d7a0-bc28-459a-9407-33bbba641c07"
  client_id       = "230411ec-45e9-4650-95b2-7675131e2d1a"
  client_secret   = "8D~7Q~y39tBTXsFXGcuVIwvGCOorRUo6dXtwX"
  tenant_id       = "70c0f6d9-7f3b-4425-a6b6-09b47643ec58"
  features {}
}
variable storage_account_name{
    type = string
    description = "Please enter the storage account name"
}

locals {
  resource_group="app-grp"
  location="North Europe"
}
# The resource block defines the type of resource we want to work with
# The name and location are arguements for the resource block

resource "azurerm_resource_group" "app_grp"{
  name=local.resource_group 
  location=local.location
}

# Here we are creating a storage account.
# The storage account service has more properties and hence there are more arguements we can specify here

resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage_account_name
  resource_group_name      = local.resource_group
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = true
  depends_on = [
      azurerm_resource_group.app_grp
  ]
}

# Here we are creating a container in the storage account
resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_name  = var.storage_account_name
  container_access_type = "blob"
  depends_on = [
      azurerm_storage_account.storage_account
  ]
}

# This is used to upload a local file onto the container
resource "azurerm_storage_blob" "sample" {
  name                   = "my-awesome-content.zip"
  storage_account_name   = var.storage_account_name
  storage_container_name = "data"
  type                   = "Block"
  source                 = "some-local-file.zip" /* source uri of staging and production website.*/

# Here we we are adding a dependency. The file can only be uploaded if the container is present
# We can access the attributes of a resource in terraform via the resource_type.resource_name

  depends_on=[azurerm_storage_container.data]

/* Existing Storage Blob's can be imported  using the resource id, e.g.

terraform import azurerm_storage_blob.blob1 https://example.blob.core.windows.net/container/blob.vhd */

}

# 2. Terraform Provider Block for AzureRM
provider "azurerm" {
  features {

  }
}

# 3. Terraform Resource Block: Define a Random Pet Resource
resource "random_pet" "aksrandom" {

}

/* For service plan terraform configuration 
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_service_plan" "plan" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux" # "Windows", "Linux"
  sku_name            = "S1"
}

resource "azurerm_linux_web_app" "app" {
  name                = var.app_service_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    # dotnet_framework_version = "v4.0" # deprecated
    always_on = false
    application_stack {
      dotnet_version = "v6.0" # "v3.0", "v4.0", "5.0", "v6.0"
    }
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
}
*/
