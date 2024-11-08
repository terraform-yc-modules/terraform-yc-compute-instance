### Datasource
data "yandex_client_config" "client" {}

### Locals
locals {
  folder_id = var.folder_id == null ? data.yandex_client_config.client.folder_id : var.folder_id
  enable_oslogin = lookup(var.enable_oslogin_or_ssh_keys, "enable-oslogin", "false")
  ssh_key = lookup(var.enable_oslogin_or_ssh_keys, "ssh_key", null)
  ssh_user = lookup(var.enable_oslogin_or_ssh_keys, "ssh_user", null)
}

data "yandex_compute_image" "image" {
  family = var.image_family
  count = var.image_family != null ? 1 : 0
}


resource "yandex_compute_instance" "this" {

  name = var.name
  platform_id        = var.platform_id
  zone               = var.zone
  description        = var.description
  hostname           = var.hostname
  folder_id          = local.folder_id
  service_account_id = var.service_account_id != null ? var.service_account_id : (var.monitoring || var.backup ? yandex_iam_service_account.sa_instance[0].id : null)
  labels             = var.labels
  metadata = merge(
    var.custom_metadata,
    var.serial_port_enable ? {"serial-port-enable" = "1"} : {},
    var.monitoring || var.backup ? {
      "user-data" = format("#cloud-config\npackages:\n  - curl\n  - perl\n  - jq\n%s\nruncmd:\n%s",
        local.ssh_key != null ? format("users:\n  - name: %s\n    sudo: ALL=(ALL) NOPASSWD:ALL\n    shell: /bin/bash\n    ssh_authorized_keys:\n      - %s",
          local.ssh_user != null ? local.ssh_user : "default_user",
          file(local.ssh_key)
        ) : "",
        join("\n", compact([
          var.backup ? "  - curl 'https://storage.yandexcloud.net/backup-distributions/agent_installer.sh' | sudo bash" : null,
          var.monitoring ? "  - wget -O - https://monitoring.api.cloud.yandex.net/monitoring/v2/unifiedAgent/config/install.sh | bash" : null
        ]))
      )
    } : {},
    local.enable_oslogin == "true" ? {
      "enable-oslogin" = local.enable_oslogin
    } : {}
  )


  allow_stopping_for_update = var.allow_stopping_for_update
  network_acceleration_type = var.network_acceleration_type
  gpu_cluster_id     = var.gpu_cluster_id
  maintenance_policy = var.maintenance_policy
  maintenance_grace_period = var.maintenance_grace_period
  resources {
    cores         = var.cores
    core_fraction = var.core_fraction
    memory        = var.memory
    gpus          = var.gpus
  }
  boot_disk {
    auto_delete = var.boot_disk_auto_delete
    device_name = var.boot_disk_device_name
    mode        = var.boot_disk_mode
    disk_id     = yandex_compute_disk.this != null ? yandex_compute_disk.this.id : var.boot_disk_disk_id

  }
  dynamic "network_interface" {
    for_each = var.network_interfaces
    content {
      subnet_id          = network_interface.value.subnet_id
      index              = lookup(network_interface.value, "index", null)
      ipv4               = lookup(network_interface.value, "ipv4", false)
      ip_address         = lookup(network_interface.value, "ip_address", null)
      nat                = lookup(network_interface.value, "nat", false)
      nat_ip_address     = lookup(network_interface.value, "nat", false) && var.static_ip != null ? yandex_vpc_address.static_ip[0].external_ipv4_address[0].address : null

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
    }
  }


dynamic "secondary_disk" {
  for_each = var.secondary_disks != null ? [for s in var.secondary_disks : s] : []
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
    placement_group_id = var.placement_policy.placement_group_id

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
    for_each = var.filesystems != null ? [for f in var.filesystems : f] : []
    content {
      filesystem_id = filesystem.value.filesystem_id != null ? filesystem.value.filesystem_id : (length(yandex_compute_filesystem.this) > filesystem.key ? yandex_compute_filesystem.this[filesystem.key].id : null)
      device_name   = filesystem.value.device_name != null ? filesystem.value.device_name : format("filesystem-%02d", filesystem.key + 1)
      mode          = filesystem.value.mode
    }
  }
  
}
