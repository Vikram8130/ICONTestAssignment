# backend.tfvars will be used to create tfstate file in terraformaks azure container

resource_group_name   = "Terraform"
storage_account_name  = "terraformeaks"
container_name        = "tfstate"
access_key            = "$ACCOUNT_KEY"
key                   = "terraform.tfstate"

