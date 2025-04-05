# Resource Group
resource "azurerm_resource_group" "resourceGroupPrimary" {
  name     = "${var.primary_resource_group_name}${local.prefixName}-001"
  location = var.primary_location_name
}

resource "azurerm_resource_group" "resourceGroupSecondry" {
  name     = "${var.secondry_resource_group_name}${local.prefixName}-001"
  location = var.secondry_location_name
}

# Network Security Groups
resource "azurerm_network_security_group" "nsg_primary" {
  name                = var.primary_nsg_name
  location            = var.primary_location_name
  resource_group_name = azurerm_resource_group.resourceGroupPrimary.name
  security_rule {
    name                       = "Inbound3389Allow"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "nsg_secondry" {
  name                = var.secondry_nsg_name
  location            = var.secondry_location_name
  resource_group_name = azurerm_resource_group.resourceGroupSecondry.name
  security_rule {
    name                       = "Inbound3389Allow"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Virtual Networks
resource "azurerm_virtual_network" "vNetPrimary" {
  name                = "${var.primary_vnet_name}${local.prefixName}-001"
  location            = var.primary_location_name
  resource_group_name = azurerm_resource_group.resourceGroupPrimary.name
  address_space       = ["10.165.1.0/27"]

  subnet {
    name           = "default"
    address_prefix = "10.165.1.0/27"
    security_group = azurerm_network_security_group.nsg_primary.id
  }

  depends_on = [azurerm_resource_group.resourceGroupPrimary]
}

resource "azurerm_virtual_network" "vNetSecondry" {
  name                = "${var.secondry_vnet_name}${local.prefixName}-001"
  location            = var.secondry_location_name
  resource_group_name = azurerm_resource_group.resourceGroupSecondry.name
  address_space       = ["10.165.2.0/27"]

  subnet {
    name           = "default"
    address_prefix = "10.165.2.0/27"
    security_group = azurerm_network_security_group.nsg_secondry.id
  }

  depends_on = [azurerm_resource_group.resourceGroupSecondry]
}

# Virtual Network Peering
resource "azurerm_virtual_network_peering" "vnet_peering_primary" {
  name                         = var.primary_vnet_peering_name
  resource_group_name          = azurerm_resource_group.resourceGroupPrimary.name
  virtual_network_name         = azurerm_virtual_network.vNetPrimary.name
  remote_virtual_network_id    = azurerm_virtual_network.vNetSecondry.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "vnet_peering_secondry" {
  name                         = var.secondry_vnet_peering_name
  resource_group_name          = azurerm_resource_group.resourceGroupSecondry.name
  virtual_network_name         = azurerm_virtual_network.vNetSecondry.name
  remote_virtual_network_id    = azurerm_virtual_network.vNetPrimary.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
}

# Virtual Machines
# The following modules are used to create the virtual machines for SQL Server, Application Server, and Domain Controller.
module "primary_sql_server" {
  source                           = "./VirtualMachine"
  server_vm_name                   = var.primary_sql_server_vm_name
  server_vm_nic_name               = var.primary_sql_server_vm_nic_name
  server_vm_public_ip_name         = var.primary_sql_server_vm_public_ip_name
  location_name                    = var.primary_location_name
  resource_group_name              = azurerm_resource_group.resourceGroupPrimary.name
  subnet_id                        = one(azurerm_virtual_network.vNetPrimary.subnet).id
  source_image_reference_publisher = "MicrosoftSQLServer"
  source_image_reference_offer     = "SQL2016SP2-WS2016"
  source_image_reference_sku       = "Enterprise"
  depends_on                       = [azurerm_virtual_network.vNetPrimary]
}

module "secondry_sql_server" {
  source                           = "./VirtualMachine"
  server_vm_name                   = var.secondry_sql_server_vm_name
  server_vm_nic_name               = var.secondry_sql_server_vm_nic_name
  server_vm_public_ip_name         = var.secondry_sql_server_vm_public_ip_name
  location_name                    = var.secondry_location_name
  resource_group_name              = azurerm_resource_group.resourceGroupSecondry.name
  subnet_id                        = one(azurerm_virtual_network.vNetSecondry.subnet).id
  source_image_reference_publisher = "MicrosoftSQLServer"
  source_image_reference_offer     = "SQL2016SP2-WS2016"
  source_image_reference_sku       = "Enterprise"
  depends_on                       = [azurerm_virtual_network.vNetSecondry]
}

module "application_server" {
  source                           = "./VirtualMachine"
  server_vm_name                   = var.application_vm_name
  server_vm_nic_name               = var.application_vm_nic_name
  server_vm_public_ip_name         = var.application_vm_public_ip_name
  location_name                    = var.primary_location_name
  resource_group_name              = azurerm_resource_group.resourceGroupPrimary.name
  subnet_id                        = one(azurerm_virtual_network.vNetPrimary.subnet).id
  source_image_reference_publisher = "MicrosoftSQLServer"
  #source_image_reference_offer     = "sql2022-ws2022"
  source_image_reference_offer     = "SQL2016SP2-WS2016"
  source_image_reference_sku       = "Enterprise"
  depends_on                       = [azurerm_virtual_network.vNetPrimary]
}

module "domain_controller" {
  source                           = "./VirtualMachine"
  server_vm_name                   = var.domaincontroller_vm_name
  server_vm_nic_name               = var.domaincontroller_vm_nic_name
  server_vm_public_ip_name         = var.domaincontroller_vm_public_ip_name
  location_name                    = var.primary_location_name
  resource_group_name              = azurerm_resource_group.resourceGroupPrimary.name
  subnet_id                        = one(azurerm_virtual_network.vNetPrimary.subnet).id
  source_image_reference_publisher = "MicrosoftWindowsServer"
  source_image_reference_offer     = "WindowsServer"
  source_image_reference_sku       = "2022-Datacenter"
  depends_on                       = [azurerm_virtual_network.vNetPrimary]
}


# Steps
# 1. Install AD
# 2. Add user in the AD and add as domain/Admins
# 3. Update DNS server in both vNet
# 4. Login all three servers and change SQL Authentication mode to SQL and enable sa login
# 5. Update DNS server in all three VMs by "ipconfig /renew"
# 6. Shift both VMs to the same domain and install failover cluster and Update free IP address from the subnet in cluster resources
# 7. Create the cluster and add both servers to the cluster
# 8. Turn on the High availability from the SQL confgiuration in both servers and shifted the SQL services to the domain user
# 9. Download Adventure Works database in primary server
      #https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver16&tabs=ssms
# 10. Restore the database in primary server and change recovery model to full and take a full backup
# 11. Add the inbound firewall rule to allow Port 1433 and 5022 in both servers
# 12. Create the availability group and add the database to the availability group
# 13. Create the listener and choose another blank IP from subnet to add for listener
# 14. Connect the listener from the application server and run update query and test both SQL server by running the select query
# 15. Test the failover by restarting the primary and secondry SQL servers