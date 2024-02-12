
resource "azurerm_public_ip" "example" {
  name                = "CI-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku = "Standard"
}

# since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "${module.example-vn.name}-beap"
  frontend_port_name             = "${module.example-vn.name}-feport"
  frontend_ip_configuration_name = "${module.example-vn.name}-feip"
  http_setting_name              = "${module.example-vn.name}-be-htst"
  listener_name                  = "${module.example-vn.name}-httplstn"
  request_routing_rule_name      = "${module.example-vn.name}-rqrt"
  redirect_configuration_name    = "${module.example-vn.name}-rdrcfg"
}

resource "azurerm_application_gateway" "example" {
  name                = "CI-gateway"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "CI-gateway-ip-configuration"
    subnet_id = module.example-vn.subnet1_id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_port {
    name = "port_443"
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.example.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 8080
    protocol              = "Http"
    request_timeout       = 60
    probe_name            = "probe"
  }


  http_listener {
    frontend_ip_configuration_name = "myVNet-feip"
    frontend_port_name             = "port_443"
    host_names                     = []
    name                           = "https"
    protocol                       = "Https"
    require_sni                    = false
    # ssl_certificate_id             = "/subscriptions/da0705d9-291c-4907-8de9-7a35dcd287d7/resourceGroups/myResourceGroup/providers/Microsoft.Network/applicationGateways/CI-gateway/sslCertificates/jenkins" -> null
    ssl_certificate_name           = "jenkins"
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    backend_address_pool_name  = "myVNet-beap"
    backend_http_settings_name = "myVNet-be-htst"
    http_listener_name         = "https"
    name                       = local.request_routing_rule_name
    priority                   = 9
    rule_type                  = "Basic"
  }

  probe {
    host                                      = "127.0.0.1"
    interval                                  = 30
    minimum_servers                           = 0
    name                                      = "probe"
    path                                      = "/login?from=%2F"
    pick_host_name_from_backend_http_settings = false
    protocol                                  = "Http"
    timeout                                   = 30
    unhealthy_threshold                       = 3
  }

  lifecycle {
    ignore_changes = [ssl_certificate]
  }
}
