data "yandex_client_config" "client" {}

data "yandex_compute_image" "image" {
  family = var.image_family
  count  = var.image_family != null && var.boot_disk.disk_id == null && var.boot_disk.image_id == null && var.boot_disk.snapshot_id == null ? 1 : 0
}


resource "yandex_compute_instance" "this" {

  name               = var.name
  platform_id        = var.platform_id
  zone               = var.zone
  description        = var.description
  hostname           = var.hostname
  folder_id          = local.folder_id
  service_account_id = local.instance_service_account_id
  labels             = var.labels
  metadata           = local.instance_metadata

  allow_stopping_for_update = var.allow_stopping_for_update
  allow_recreate            = var.allow_recreate
  network_acceleration_type = var.network_acceleration_type
  gpu_cluster_id            = var.gpu_cluster_id
  maintenance_policy        = var.maintenance_policy
  maintenance_grace_period  = var.maintenance_grace_period
  reserved_instance_pool_id = var.reserved_instance_pool_id

  dynamic "metadata_options" {
    for_each = var.metadata_options == null ? [] : [var.metadata_options]
    content {
      gce_http_endpoint    = metadata_options.value.gce_http_endpoint
      gce_http_token       = metadata_options.value.gce_http_token
      aws_v1_http_endpoint = metadata_options.value.aws_v1_http_endpoint
      aws_v1_http_token    = metadata_options.value.aws_v1_http_token
      aws_v2_http_endpoint = metadata_options.value.aws_v2_http_endpoint
      aws_v2_http_token    = metadata_options.value.aws_v2_http_token
    }
  }

  dynamic "local_disk" {
    for_each = var.local_disks
    content {
      size_bytes = local_disk.value.size_bytes
      kms_key_id = local_disk.value.kms_key_id
    }
  }

  resources {
    cores         = var.cores
    core_fraction = var.core_fraction
    memory        = var.memory
    gpus          = var.gpus
  }
  boot_disk {
    auto_delete = lookup(var.boot_disk, "auto_delete", true)
    device_name = lookup(var.boot_disk, "device_name", "boot-disk")
    mode        = lookup(var.boot_disk, "mode", "READ_WRITE")
    disk_id     = var.boot_disk.disk_id != null ? var.boot_disk.disk_id : yandex_compute_disk.this[0].id
  }
  dynamic "network_interface" {
    for_each = var.network_interfaces
    content {
      subnet_id    = network_interface.value.subnet_id
      index        = lookup(network_interface.value, "index", null)
      ipv4         = lookup(network_interface.value, "ipv4", false)
      ip_address   = lookup(network_interface.value, "ip_address", null)
      ipv6         = lookup(network_interface.value, "ipv6", null)
      ipv6_address = lookup(network_interface.value, "ipv6_address", null)
      nat          = network_interface.value.nat
      nat_ip_address = network_interface.value.nat ? (
        network_interface.value.nat_ip_address != null ? network_interface.value.nat_ip_address :
        (network_interface.key == local.managed_static_ip_network_interface_index ? yandex_vpc_address.static_ip[0].external_ipv4_address[0].address : null)
      ) : null

      security_group_ids = lookup(network_interface.value, "security_group_ids", null)

      dynamic "dns_record" {
        for_each = lookup(network_interface.value, "dns_record", [])
        content {
          fqdn        = dns_record.value.fqdn
          dns_zone_id = lookup(dns_record.value, "dns_zone_id", null)
          ttl         = lookup(dns_record.value, "ttl", null)
          ptr         = lookup(dns_record.value, "ptr", false)
        }
      }

      dynamic "ipv6_dns_record" {
        for_each = lookup(network_interface.value, "ipv6_dns_record", [])
        content {
          fqdn        = ipv6_dns_record.value.fqdn
          dns_zone_id = lookup(ipv6_dns_record.value, "dns_zone_id", null)
          ttl         = lookup(ipv6_dns_record.value, "ttl", null)
          ptr         = lookup(ipv6_dns_record.value, "ptr", false)
        }
      }

      dynamic "nat_dns_record" {
        for_each = lookup(network_interface.value, "nat_dns_record", [])
        content {
          fqdn        = nat_dns_record.value.fqdn
          dns_zone_id = lookup(nat_dns_record.value, "dns_zone_id", null)
          ttl         = lookup(nat_dns_record.value, "ttl", null)
          ptr         = lookup(nat_dns_record.value, "ptr", false)
        }
      }
    }
  }


  dynamic "secondary_disk" {
    for_each = var.secondary_disks
    content {
      disk_id     = secondary_disk.value.disk_id != null ? secondary_disk.value.disk_id : yandex_compute_disk.secondary[secondary_disk.key].id
      auto_delete = secondary_disk.value.auto_delete
      device_name = secondary_disk.value.device_name != null ? secondary_disk.value.device_name : format("secondary-disk-%02d", secondary_disk.key + 1)
      mode        = secondary_disk.value.mode
    }
  }

  scheduling_policy {
    preemptible = var.scheduling_policy_preemptible
  }

  placement_policy {
    placement_group_id        = var.placement_policy.placement_group_id
    placement_group_partition = var.placement_policy.placement_group_partition

    dynamic "host_affinity_rules" {
      for_each = var.placement_policy.host_affinity_rules != null ? [for r in var.placement_policy.host_affinity_rules : r] : []
      content {
        key    = host_affinity_rules.value.key
        op     = host_affinity_rules.value.op
        values = host_affinity_rules.value.values
      }
    }
  }


  dynamic "filesystem" {
    for_each = var.filesystems
    content {
      filesystem_id = filesystem.value.filesystem_id != null ? filesystem.value.filesystem_id : yandex_compute_filesystem.this[filesystem.key].id
      device_name   = filesystem.value.device_name != null ? filesystem.value.device_name : format("filesystem-%02d", filesystem.key + 1)
      mode          = filesystem.value.mode
    }
  }

  lifecycle {
    precondition {
      condition     = !(var.user_data != null && local.custom_user_data != null)
      error_message = "Set only one of user_data and custom_metadata[\"user-data\"] so cloud-init precedence is explicit."
    }

    precondition {
      condition = try(var.static_ip == null ? true : (
        var.static_ip.network_interface_index == null ?
        length(local.eligible_managed_static_ip_network_interface_indexes) == 1 :
        (var.static_ip.network_interface_index < length(var.network_interfaces) &&
          var.network_interfaces[var.static_ip.network_interface_index].nat &&
        var.network_interfaces[var.static_ip.network_interface_index].nat_ip_address == null)
      ), false)
      error_message = "static_ip must select exactly one NAT interface without nat_ip_address. Set static_ip.network_interface_index when more than one NAT interface is eligible; an explicit nat_ip_address takes precedence and cannot use a module-managed static IP."
    }
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_member.sa_monitoring,
    yandex_resourcemanager_folder_iam_member.sa_backup,
  ]
}
