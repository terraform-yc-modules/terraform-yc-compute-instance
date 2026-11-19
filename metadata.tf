locals {
  legacy_generated_user_data = local.install_monitoring_agent || local.install_backup_agent ? format("#cloud-config\npackages:\n  - curl\n  - perl\n  - jq\n%s\nruncmd:\n%s",
    local.ssh_key != null ? format("users:\n  - name: %s\n    sudo: ALL=(ALL) NOPASSWD:ALL\n    shell: /bin/bash\n    ssh_authorized_keys:\n      - %s",
      local.ssh_user != null ? local.ssh_user : "default_user",
      file(local.ssh_key)
    ) : "",
    join("\n", compact([
      local.install_backup_agent ? "  - curl 'https://storage.yandexcloud.net/backup-distributions/agent_installer.sh' | sudo bash" : null,
      local.install_monitoring_agent ? "  - wget -O - https://monitoring.api.cloud.yandex.net/monitoring/v2/unifiedAgent/config/install.sh | bash" : null,
    ]))
    ) : local.ssh_key != null ? format("#cloud-config\nusers:\n  - name: %s\n    sudo: ALL=(ALL) NOPASSWD:ALL\n    shell: /bin/bash\n    ssh_authorized_keys:\n      - %s",
    local.ssh_user != null ? local.ssh_user : "default_user",
    file(local.ssh_key)
  ) : ""

  structured_cloud_config = merge(
    local.ssh_public_key != null ? {
      users = [{
        name                = local.ssh_user != null ? local.ssh_user : "default_user"
        sudo                = "ALL=(ALL) NOPASSWD:ALL"
        shell               = "/bin/bash"
        ssh_authorized_keys = [local.ssh_public_key]
      }]
      } : (local.ssh_key != null ? {
        users = [{
          name                = local.ssh_user != null ? local.ssh_user : "default_user"
          sudo                = "ALL=(ALL) NOPASSWD:ALL"
          shell               = "/bin/bash"
          ssh_authorized_keys = [file(local.ssh_key)]
        }]
    } : {}),
    local.install_monitoring_agent || local.install_backup_agent ? {
      packages = ["curl", "perl", "jq"]
      runcmd = compact([
        local.install_backup_agent ? "curl 'https://storage.yandexcloud.net/backup-distributions/agent_installer.sh' | sudo bash" : null,
        local.install_monitoring_agent ? "wget -O - https://monitoring.api.cloud.yandex.net/monitoring/v2/unifiedAgent/config/install.sh | bash" : null,
      ])
    } : {},
  )

  structured_generated_user_data = length(keys(local.structured_cloud_config)) == 0 ? "" : "#cloud-config\n${yamlencode(local.structured_cloud_config)}"
  use_legacy_generated_user_data = local.ssh_public_key == null && var.install_monitoring_agent == null && var.install_backup_agent == null
  generated_user_data            = local.use_legacy_generated_user_data ? local.legacy_generated_user_data : local.structured_generated_user_data
  custom_user_data               = lookup(var.custom_metadata, "user-data", null)
  instance_metadata = merge(
    { for key, value in var.custom_metadata : key => value if key != "user-data" },
    var.serial_port_enable ? { "serial-port-enable" = "1" } : {},
    { "user-data" = var.user_data != null ? var.user_data : (local.custom_user_data != null ? local.custom_user_data : local.generated_user_data) },
    local.enable_oslogin == "true" ? { "enable-oslogin" = local.enable_oslogin } : {},
  )
}
