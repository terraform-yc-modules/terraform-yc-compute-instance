locals {
  folder_id      = var.folder_id == null ? data.yandex_client_config.client.folder_id : var.folder_id
  enable_oslogin = lookup(var.enable_oslogin_or_ssh_keys, "enable-oslogin", "false")
  ssh_key        = lookup(var.enable_oslogin_or_ssh_keys, "ssh_key", null)
  ssh_public_key = lookup(var.enable_oslogin_or_ssh_keys, "ssh_public_key", null)
  ssh_user       = lookup(var.enable_oslogin_or_ssh_keys, "ssh_user", null)

  eligible_managed_static_ip_network_interface_indexes = [
    for index, network_interface in var.network_interfaces : index
    if network_interface.nat && network_interface.nat_ip_address == null
  ]
  managed_static_ip_network_interface_index = var.static_ip == null ? null : (
    var.static_ip.network_interface_index != null ? var.static_ip.network_interface_index :
    (length(local.eligible_managed_static_ip_network_interface_indexes) == 1 ? local.eligible_managed_static_ip_network_interface_indexes[0] : null)
  )
}
