##############################################################################
# * Beginner's Guide to Using Terraform on Azure
# 
# This Terraform configuration will create the following:
#
# This will create a Resource group with a virtual network and subnet
# Along with a Windows Server Running IIS.
# All Variables are pulled from Variables.tf



# Resource Group Resource
resource "azurerm_resource_group" "test_terraform_usnc_rg" {
    name = "${var.resource.group}"
    location = "${var.location}"
}

# Virtual Network Resource 
resource "azurerm_virtual_network" "test_terraform_vnet" {
    name = "${var.virtual.network.name}"
    location = "${azurerm_resource_group.test_terraform_usnc_rg.location}"
    address_space = "$[var.address_space]"
    resource_group_name = "${azurerm_resource_group.test_terraform_usnc_rg.name}"
}

# Virtual Network Subnet Resource
resource "azurerm_subnet" "test_terraform_subnet" {
    name = "${var.prefix}subnet"
    virtual_network_name = "${azurerm_virtual_network.name}"
    resource_group_name = "${azurerm_resource_group.test_terraform_usnc_rg.name}"
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









#


