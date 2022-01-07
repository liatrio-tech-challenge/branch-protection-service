resource "github_organization_webhook" "branch_protection_service" {
  configuration {
    #    url          = "https://${azurerm_function_app.branch_protection_service.name}.azurewebsites.net/api/branch-protection"
    url          = "https://ghe-org-mgmt.ngrok.io/api/branch-protection"
    content_type = "json"
    insecure_ssl = false
    secret       = var.github_webhook_secret
  }

  active = true

  events = ["repository"]
}
