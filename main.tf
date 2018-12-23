##############################################################################
# * Beginner's Guide to Using Terraform on Azure
# 
# This Terraform configuration will create the following:
#
# Resource group with a virtual network and subnet
# An Windows Server Running IIS

resource "azurerm_resource_group" "test_terraform_rg" {
    name = "${var.resource.group}"
    location "${var.location}"
}


