resource "github_organization_webhook" "branch_protection_service" {
  configuration {
    url          = "https://${azurerm_function_app.branch_protection_service.name}.azurewebsites.net"
    content_type = "json"
    insecure_ssl = false
  }

  active = false

  events = ["repository"]
}

resource "github_organization_webhook" "test" {
  configuration {
    url          = "https://ghe-org-mgmt.ngrok.io"
    content_type = "json"
    insecure_ssl = false
  }

  active = false

  events = ["repository"]
}