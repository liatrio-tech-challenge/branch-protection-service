resource "azurerm_resource_group" "github_tech_challenge" {
  location = var.location
  name     = "github-tech-challenge"
}

resource "azurerm_storage_account" "branch_protection_service" {
  name                     = "liatriogithubtech"
  resource_group_name      = azurerm_resource_group.github_tech_challenge.name
  location                 = azurerm_resource_group.github_tech_challenge.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "branch_protection_service" {
  name                = "github-branch-protection-service"
  location            = azurerm_resource_group.github_tech_challenge.location
  resource_group_name = azurerm_resource_group.github_tech_challenge.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "branch_protection_service" {
  name                       = "github-branch-protection-service"
  location                   = azurerm_resource_group.github_tech_challenge.location
  resource_group_name        = azurerm_resource_group.github_tech_challenge.name
  app_service_plan_id        = azurerm_app_service_plan.branch_protection_service.id
  storage_account_name       = azurerm_storage_account.branch_protection_service.name
  storage_account_access_key = azurerm_storage_account.branch_protection_service.primary_access_key

  app_settings = {
    WEBHOOK_SECRET: var.github_webhook_secret
    GITHUB_TOKEN: var.github_webhook_secret
  }
}
