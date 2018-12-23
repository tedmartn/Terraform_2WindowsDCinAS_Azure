##############################################################################
# Variables File
# 
# Here is where we store the default values for all the variables used in our
# Terraform code. If you create a variable with no default, the user will be
# prompted to enter it (or define it via config file or command line flags.)

variable "resource_group" {
    description = " The name of your Azure Resource Group"
    default = "Terraform-USNC-RG"
}

variable "prefix" {
    description = "This prefix will be included in the name of some resources"
    default = "tfguide"
}

variable "hostname" {
    description = "This is the name of your virtual machine"
    default = "usnc-tf-wintest"
}

variable "location" {
    description = "The region your resources will be created"
    default = "northcentralus"
}

variable "virtual_network_name" {
    description = "The name of your virtual network"
    default = "terraform_vnet"
}

variable "address_space" {
    description = "Top level Networking Scheme"
    default = "10.0.0.0/16"
}

variable "subnet_prefix" {
    description = "Address Prefix used by the subnet"
    default = "10.0.1.0/24"
}

variable "storage_account_tier" {
    description = "Defined the type of storage account used"
    default = "Standard"
}

variable "storage_replication_type" {
    description = "Defines the type of replication used by the storage account"
    default = "LRS"
}

variable "vm_size" {
    description = "The specific VM Size utilized"
    default = "Standard_DS2_v2"
}

variable "image_publisher" {
    description = "The name of the publisher of the image (az vm image list)"
    default = "MicrosoftWindowsServer"
}

variable "image_offer" {
  description = "The name of the offer of the image (az vm image list --output table)"
  default = "WindowsServer"
}

variable "image_sku" {
    description = "The name of the sku of the image (az vm image list --output table)"
    default = "2016-Datacenter"
}

variable "image_version" {
    description = "The version of the image you watn to apply (az vm image list --output table)"
    default = "latest"
}

variable "admin_username" {
    description = "Name of the username account"
    default = "rkdtmartin"
}

variable "admin_password" {
    description = "Password for Admin Account"
    default = "G3tstompt92!"
}

variable "source_network" {
    description = "Allow access from this network prefix, defaults at '*'."
    default = "*"
}







