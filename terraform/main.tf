provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "RG-Rakbank-proj-RnD"
  location = "Central India"
}

# Backend App Service Plan (Windows)
resource "azurerm_service_plan" "backend_plan" {
  name                = "backend-service-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Windows"

  sku_name = "F1"  # Free tier
}

# Backend App Service
resource "azurerm_app_service" "backend_app" {
  name                = "backend-api-demo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.backend_plan.id

  site_config {
    python_version = "3.4"  # Adjusted to a supported version
  }
}

# Frontend App Service Plan (Linux)
resource "azurerm_service_plan" "frontend_plan" {
  name                = "frontend-service-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"

  sku_name = "F1"  # Free tier
}

# Frontend App Service
resource "azurerm_app_service" "frontend_app" {
  name                = "frontend-api-demo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.frontend_plan.id

  site_config {
    linux_fx_version = "NODE|18-lts"
  }
}

output "backend_app_url" {
  value = azurerm_app_service.backend_app.default_site_hostname
}

output "frontend_app_url" {
  value = azurerm_app_service.frontend_app.default_site_hostname
}
