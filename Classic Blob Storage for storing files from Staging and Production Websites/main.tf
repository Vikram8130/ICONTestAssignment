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

# We can connect to our storage account either via public IP address or service endpoints, or privately using a privte endpoints.

/* 

** Below commands can be used  in azure pielines from staging and prod website.

-> azcopy login

We  can use the azcopy make command to create a file share.

->  azcopy make 'https://<storage-account-name>.file.core.windows.net/<file-share-name><SAS-token>'

-> Azcopy copy " <Source File>" "<storage_account_name>.<blob>.core.windows.net/<containername>?<SAS token>"

-> azcopy copy '<local-file-path>' 'https://<storage-account-name>.file.core.windows.net/<file-share-name>/<file-name><SAS-token>'

eg. azcopy copy 'C:\myDirectory\myTextFile.txt' 
'https://mystorageaccount.file.core.windows.net/myfileshare/myTextFile.txt?sv=2018-03-28&ss=bjqt&srs=sco&sp=rjklhjup&se=2019-05-10T04:37:48Z&st=2019-05-09T20:37:48Z&spr=https&sig=%2FSOVEFfsKDqRry4bk3qz1vAQFwY5DDzp2%2B%2F3Eykf%2FJLs%3D'
 --preserve-smb-permissions=true --preserve-smb-info=true

-> azcopy copy '<local-directory-path>/*' 'https://<storage-account-name>.file.core.windows.net/<file-share-name>/<directory-path><SAS-token>' --recursive

Below artile can be referred for above steps.

https://cloud.netapp.com/blog/azure-cvo-blg-how-to-upload-files-to-azure-blob-storage

https://www.sqlshack.com/use-azcopy-to-upload-data-to-azure-blob-storage/

OR

-> Below command can be used  in azure pielines to upload files from different environment website.

trigger:
- stage

pool:
  vmImage: windows-latest
steps:
 #Copy files to Azure Blob Storage
- task: AzureFileCopy@4
  inputs:
    sourcePath: 'https://someonesbackups.blob.core.windows.net/backups?mysastokengoeshere'
    azureSubscription: MY-Staging-Subscription
    destination: azureBlob
    storage: azcopypipelinetest
    containerName: restored
    additionalArgumentsForBlobCopy: --recursive=true

*/

# Above Templates can be imported to the upgraded architecture as per the business needs and decision. 
