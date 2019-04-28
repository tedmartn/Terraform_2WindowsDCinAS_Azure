##############################################################################
# * Beginner's Guide to Using Terraform on Azure
# 
# This Terraform configuration will create the following:
#
# This will create a Resource group with a virtual network and subnet
# Along with a Windows Server Running IIS.
# All Variables are pulled from Variables.tf
# Goals for this Configuration Below 
# Set-up Two Domain Controllers for domain availability redundancy 
# Add both of these DC's in an Availability Set for highest SLA 99.95%
#
#
#
#




# Resource Group Resource
resource "azurerm_resource_group" "usnc_domainsetup_rg" {
    name = "${var.resource_group}"
    location = "${var.location}"

    tags {
        environment = "Terraform Domain Set-up"
    }
}

# Azure VNET Resource 
resource "azurerm_virtual_network" "vnet" {
    name = "${var.virtual_network_name}"
    location = "${azurerm_resource_group.usnc_domainsetup_rg.location}"
    address_space = ["${var.address_space}"]
    resource_group_name = "${azurerm_resource_group.usnc_domainsetup_rg.name}"

    tags {
        environment = "Terraform Domain Set-up"
    }
}

# Azure VNET Subnet Resource
resource "azurerm_subnet" "subnet" {
    name = "${var.prefix}subnet"
    virtual_network_name = "${azurerm_virtual_network.vnet.name}"
    resource_group_name = "${azurerm_resource_group.usnc_domainsetup_rg.name}"
    address_prefix = "${var.subnet_prefix}"  
    
}

##############################################################################
# * Build an Windows Server 2016 Datacenter VM
#
# Now that we have a network, we'll deploy an Windows Server 2016.
# An Azure Virtual Machine has several components. In this example we'll build
# a security group, a network interface, a public ip address, a storage 
# account and finally the VM itself. Terraform handles all the dependencies 
# automatically, and each resource is named with user-defined variables.

# Azure NSG Resource, this controls inbound/outbound ACL's on the associated Network Interface
resource "azurerm_network_security_group" "test_terraform_nsg" {
  name = "${var.prefix}-sg"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.usnc_domainsetup_rg.name}"

    security_rule {
    name = "HTTP"
    priority = 100
    direction ="Inbound"
    access = "allow"
    protocol = "tcp"
    source_port_range = "*"
    destination_port_range = "80"
    source_address_prefix = "${var.source_network}"
    destination_address_prefix = "*"
    }

    security_rule {
    name = "RDP"
    priority = 101
    direction = "Inbound"
    access = "allow"
    protocol = "tcp"
    source_port_range = "*"
    destination_port_range = "3389"
    source_address_prefix = "${var.source_network}"
    destination_address_prefix = "*"
    }

    tags {
        environment = "Terraform Domain Set-up"
    }
}


# Network Interface Resource for the Windows VM
resource "azurerm_network_interface" "terraform_test_windowsnic" {
    name = "${var.prefix}terraform_test_windowsnic"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.usnc_domainsetup_rg.name}"
    network_security_group_id ="${azurerm_network_security_group.test_terraform_nsg.id}"


    ip_configuration {
        name = "${var.prefix}ipconfig"
        subnet_id = "${azurerm_subnet.subnet.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = "${azurerm_public_ip.terraform_test_pip.id}"
    }

    tags {
        environment = "Terraform Domain Set-up"
    }
}


# Public IP Resource 
resource "azurerm_public_ip" "terraform_test_pip" {
    name = "${var.prefix}-ip"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.usnc_domainsetup_rg.name}"
    public_ip_address_allocation = "Dynamic"
    domain_name_label = "${var.hostname}"

    tags {
        environment = "Terraform Domain Set-up"
    }
}


# Settings for our Windows Virtual Machine
resource "azurerm_virtual_machine" "website" {
    name = "${var.hostname}-site"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.usnc_domainsetup_rg.name}"
    vm_size = "${var.vm_size}"

    network_interface_ids = ["${azurerm_network_interface.terraform_test_windowsnic.id}"]
    delete_os_disk_on_termination = "true"


    storage_image_reference {
        publisher = "${var.image_publisher}"
        offer = "${var.image_offer}"
        sku = "${var.image_sku}"
        version = "${var.image_version}"
    }

    storage_os_disk {
        name = "${var.hostname}-osdisk"
        managed_disk_type = "Standard_LRS"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = "${var.hostname}"
        admin_username = "${var.admin_username}"
        admin_password = "${var.admin_password}"
    }

    os_profile_windows_config {
        provision_vm_agent = "true"
        enable_automatic_upgrades = "true"
        timezone = "Central Standard Time"

    }
    tags {
        environment = "Terraform Domain Set-up"
    }
}


resource "azurerm_virtual_machine_extension" "iiswebextension" {
    name = "${var.vm_extension}"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.usnc_domainsetup_rg.name}"
    virtual_machine_name = "${azurerm_virtual_machine.website.name}"
    publisher            = "Microsoft.Powershell"
    type                 = "DSC"
    type_handler_version = "2.20"
    depends_on = ["azurerm_virtual_machine.website"]

    settings = <<SETTINGS
    {
        "configuration" : {
            "url" : "https://usnctestps1sa.blob.core.windows.net/iiswebserver/iiswebservers.zip",
            "script" : "iiswebserver.ps1",
            "function" : "Webserver"
        }
    }
SETTINGS

    tags {
        environment = "Terraform Domain Set-up"
    }

}