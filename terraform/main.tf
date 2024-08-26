provider "azurerm" {
  features {}  # This should be a block, not an argument
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
  kind                = "Windows"
  reserved            = false

  sku {
    tier = "Free"
    size = "F1"
  }
}

# Backend App Service
resource "azurerm_app_service" "backend_app" {
  name                = "backend-api-demo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_service_plan.backend_plan.id

  site_config {
    # Adjust this to a supported Python version or use a custom container
    python_version = "3.4"  # Or use "linux_fx_version" if you need Python 3.10
  }
}

# Frontend App Service Plan (Linux)
resource "azurerm_service_plan" "frontend_plan" {
  name                = "frontend-service-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Free"
    size = "F1"
  }
}

# Frontend App Service
resource "azurerm_app_service" "frontend_app" {
  name                = "frontend-api-demo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_service_plan.frontend_plan.id

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
