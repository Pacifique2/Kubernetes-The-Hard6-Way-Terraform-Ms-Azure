output "rsg_name" {
  value = "${azurerm_resource_group.terraform_test.name}"
}

output "rsg_location" {
  value = "${azurerm_resource_group.terraform_test.location}"
}

output "subnet_id" {
  value = "${azurerm_subnet.kube_vnet_subnet.id}"
}
