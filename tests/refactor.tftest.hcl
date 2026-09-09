mock_provider "random" {}

mock_provider "yandex" {}

run "legacy_defaults_keep_a_module_created_boot_disk_at_the_moved_address" {
  command = plan

  variables {
    name      = "legacy-default-regression"
    folder_id = "test-folder"
    zone      = "ru-central1-a"

    enable_oslogin_or_ssh_keys = {
      enable-oslogin = "true"
    }

    network_interfaces = [{
      subnet_id = "test-subnet"
      nat       = true
    }]
  }

  assert {
    condition     = length(yandex_compute_disk.this) == 1
    error_message = "Legacy defaults must retain a module-created boot disk at yandex_compute_disk.this[0]."
  }
}

run "external_storage_is_attached_without_module_creation" {
  command = plan

  variables {
    name      = "refactor-regression"
    folder_id = "test-folder"
    zone      = "ru-central1-a"

    enable_oslogin_or_ssh_keys = {
      enable-oslogin = "true"
    }

    network_interfaces = [{
      subnet_id = "test-subnet"
      nat       = true
    }]

    boot_disk = {
      disk_id     = "external-boot-disk"
      auto_delete = false
    }

    secondary_disks = [
      {
        disk_id     = "external-secondary-disk"
        auto_delete = false
      },
      {
        size = 20
      },
    ]

    filesystems = [
      {
        filesystem_id = "external-filesystem"
      },
      {
        size = 20
        zone = "ru-central1-a"
      },
    ]
  }

  assert {
    condition     = length(yandex_compute_disk.this) == 0 && length(yandex_compute_disk.secondary) == 1 && length(yandex_compute_filesystem.this) == 1
    error_message = "The module must not create resources for externally supplied boot disks, secondary disks, or filesystems."
  }
}

run "ambiguous_managed_static_ip_requires_a_selected_interface" {
  command = plan

  expect_failures = [yandex_compute_instance.this]

  variables {
    name      = "static-ip-regression"
    folder_id = "test-folder"
    zone      = "ru-central1-a"

    enable_oslogin_or_ssh_keys = {
      enable-oslogin = "true"
    }

    network_interfaces = [
      {
        subnet_id = "test-subnet-a"
        nat       = true
      },
      {
        subnet_id = "test-subnet-b"
        nat       = true
      },
    ]

    static_ip = {
      external_ipv4_address = {
        zone_id = "ru-central1-a"
      }
    }
  }
}

run "selected_managed_static_ip_is_accepted" {
  command = plan

  variables {
    name      = "selected-static-ip-regression"
    folder_id = "test-folder"
    zone      = "ru-central1-a"

    enable_oslogin_or_ssh_keys = {
      enable-oslogin = "true"
    }

    network_interfaces = [
      {
        subnet_id = "test-subnet-a"
        nat       = true
      },
      {
        subnet_id = "test-subnet-b"
        nat       = true
      },
    ]

    static_ip = {
      network_interface_index = 1
      external_ipv4_address = {
        zone_id = "ru-central1-a"
      }
    }
  }
}

run "custom_user_data_is_not_overwritten_by_generated_metadata" {
  command = plan

  variables {
    name      = "metadata-regression"
    folder_id = "test-folder"
    zone      = "ru-central1-a"

    enable_oslogin_or_ssh_keys = {
      enable-oslogin = "true"
    }

    network_interfaces = [{
      subnet_id = "test-subnet"
      nat       = true
    }]

    custom_metadata = {
      "user-data" = "#cloud-config\nruncmd:\n  - echo custom-marker"
    }
  }

  assert {
    condition     = yandex_compute_instance.this.metadata["user-data"] == "#cloud-config\nruncmd:\n  - echo custom-marker"
    error_message = "custom_metadata user-data must remain authoritative when no explicit user_data is set."
  }
}

run "explicit_user_data_is_authoritative_over_agent_generation" {
  command = plan

  variables {
    name       = "raw-user-data-regression"
    folder_id  = "test-folder"
    zone       = "ru-central1-a"
    monitoring = true
    user_data  = "#cloud-config\nruncmd:\n  - echo explicit-marker"

    enable_oslogin_or_ssh_keys = {
      enable-oslogin = "true"
    }

    network_interfaces = [{
      subnet_id = "test-subnet"
      nat       = true
    }]
  }

  assert {
    condition     = yandex_compute_instance.this.metadata["user-data"] == "#cloud-config\nruncmd:\n  - echo explicit-marker"
    error_message = "Explicit user_data must not be amended or replaced by generated agent commands."
  }
}

run "ssh_public_key_content_generates_cloud_config_without_a_local_file" {
  command = plan

  variables {
    name      = "ssh-content-regression"
    folder_id = "test-folder"
    zone      = "ru-central1-a"

    enable_oslogin_or_ssh_keys = {
      ssh_user       = "test-user"
      ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAITestKey test@example"
    }

    network_interfaces = [{
      subnet_id = "test-subnet"
      nat       = true
    }]
  }

  assert {
    condition     = strcontains(yandex_compute_instance.this.metadata["user-data"], "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAITestKey test@example")
    error_message = "SSH public-key content must be rendered into generated cloud-config without requiring ssh_key path."
  }
}

run "external_service_account_roles_require_explicit_opt_in" {
  command = plan

  variables {
    name                       = "external-sa-regression"
    folder_id                  = "test-folder"
    zone                       = "ru-central1-a"
    monitoring                 = true
    service_account_id         = "external-service-account"
    manage_service_account_iam = true

    enable_oslogin_or_ssh_keys = {
      enable-oslogin = "true"
    }

    network_interfaces = [{
      subnet_id = "test-subnet"
      nat       = true
    }]
  }

  assert {
    condition     = length(yandex_resourcemanager_folder_iam_member.sa_monitoring) == 1
    error_message = "External service-account IAM management must be possible only through explicit opt-in."
  }
}

run "agent_installation_can_be_disabled_without_disabling_legacy_monitoring_input" {
  command = plan

  variables {
    name                     = "agent-regression"
    folder_id                = "test-folder"
    zone                     = "ru-central1-a"
    monitoring               = true
    install_monitoring_agent = false

    enable_oslogin_or_ssh_keys = {
      enable-oslogin = "true"
    }

    network_interfaces = [{
      subnet_id = "test-subnet"
      nat       = true
    }]
  }

  assert {
    condition     = !strcontains(yandex_compute_instance.this.metadata["user-data"], "monitoring/v2/unifiedAgent/config/install.sh") && length(yandex_resourcemanager_folder_iam_member.sa_monitoring) == 1
    error_message = "install_monitoring_agent=false must prevent generated installation while retaining IAM for the enabled, preinstalled agent."
  }
}
