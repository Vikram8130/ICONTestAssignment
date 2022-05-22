# Template for Uploading files from Staging Website to Classic Blob Storage
resource "azurerm_app_service_plan" "websiteappserviceplan" {
  name                = "appserviceplan-dgyn27h2dfoyojc"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  sku {
    tier = "Standard"
    size = "B1"
  }
}

resource "azurerm_app_service" "website_app" {
  name                = var.website_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  app_service_plan_id = azurerm_app_service_plan.websiteappserviceplan.id

  #storage_account {
    #name       = azurerm_storage_account.website_logs_key.name
    #type       = "AzureBlob" 
    #access_key = lookup(azurerm_storage_account.value,"access_key")
  #}

  app_settings = {
    "KEY_VAULT_URL"                        = azurerm_key_vault.nscsecrets.vault_uri
    "DIAGNOSTICS_AZUREBLOBCONTAINERSASURL" = azurerm_storage_container.website_logs_container.name
    "DIAGNOSTICS_AZUREBLOBRETENTIONINDAYS" = 365
  }

  connection_string {
    name  = "StorageAccount"
    type  = "Custom"
    value = azurerm_storage_account.website_log_storage.primary_connection_string

  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "stage"
  }
}

# Template for Uploading files from Production Website to Classic Blob Storage

resource "azurerm_app_service_plan" "websiteappserviceplan" {
  name                = "appserviceplan-dgyn27h2dfoyojc"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  sku {
    tier = "Standard"
    size = "S2"
  }
}

resource "azurerm_app_service" "website_app" {
  name                = var.website_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  app_service_plan_id = azurerm_app_service_plan.websiteappserviceplan.id

  #storage_account {
    #name       = azurerm_storage_account.website_logs_key.name
    #type       = "AzureBlob" 
    #access_key = lookup(azurerm_storage_account.value,"access_key")
  #}

  app_settings = {
    "KEY_VAULT_URL"                        = azurerm_key_vault.nscsecrets.vault_uri
    "DIAGNOSTICS_AZUREBLOBCONTAINERSASURL" = azurerm_storage_container.website_logs_container.name
    "DIAGNOSTICS_AZUREBLOBRETENTIONINDAYS" = 365
  }

  connection_string {
    name  = "StorageAccount"
    type  = "Custom"
    value = azurerm_storage_account.website_log_storage.primary_access_key
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "prod"
  }
}

# Above Templates can be imported to the upgraded architecture as per the business needs and decision. 
