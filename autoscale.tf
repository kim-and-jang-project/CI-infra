locals {
  first_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+wWK73dCr+jgQOAxNsHAnNNNMEMWOHYEccp6wJm2gotpr9katuF/ZAdou5AaW1C61slRkHRkpRRX9FA9CYBiitZgvCCz+3nWNN7l/Up54Zps/pHWGZLHNJZRYyAB6j5yVLMVHIHriY49d/GZTZVNB8GoJv9Gakwc/fuEZYYl4YDFiGMBP///TzlI4jhiJzjKnEvqPFki5p2ZRJqcbCiF4pJrxUQR/RXqVFQdbRLZgYfJ8xGB878RENq3yQ39d8dVOkq4edbkzwcUmwwwkYVPIoDGsYLaRHnG+To7FvMeyO7xDVQkMKzopTQV8AuKpyvpqu0a9pWOMaiCyDytO7GGN you@me.com"
}


resource "azurerm_linux_virtual_machine_scale_set" "example" {
  name                = "example-vmss"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard_B2s"
  instances           = 1
  admin_username      = "adminuser"
  vtpm_enabled = true
  secure_boot_enabled = true

 

  admin_ssh_key {
    username   = "adminuser"
    public_key = local.first_public_key
  }

   source_image_id = "/subscriptions/da0705d9-291c-4907-8de9-7a35dcd287d7/resourceGroups/myResourceGroup/providers/Microsoft.Compute/galleries/newgallery/images/jenkinsIMG/versions/1.0.2"
  

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "example"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = module.example-vn.subnet2_id
      application_gateway_backend_address_pool_ids = ["/subscriptions/da0705d9-291c-4907-8de9-7a35dcd287d7/resourceGroups/myResourceGroup/providers/Microsoft.Network/applicationGateways/CI-gateway/backendAddressPools/myVNet-beap"]
    }


  }
}
