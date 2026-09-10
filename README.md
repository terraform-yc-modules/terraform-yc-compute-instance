# Compute Instance Terraform Module for Yandex.Cloud

 ## Features

- **Compute Instance**: Create a Yandex.Cloud compute instance with customizable resources.
- **Disks**: Attach multiple disks, including boot and secondary disks, with custom settings.
- **Network Interfaces**: Configure multiple network interfaces with options for NAT, static IP, and DNS records.
- **Static IP**: Optionally assign a static IP to the instance.
- **Filesystem**: Attach a Yandex.Cloud Filesystem to the instance.
- **Monitoring and Backup**: Enable monitoring and backup services using Yandex.Cloud's predefined scripts.

`static_ip` selects one NAT interface: set `network_interface_index` for a multi-NIC instance, while a single eligible NAT interface stays compatible. Explicit NIC `nat_ip_address` wins and cannot share the same managed allocation. `user_data` is raw authoritative cloud-init; it is never amended with generated SSH or agent commands. See [migration notes](docs/MIGRATION.md) before changing an existing boot disk to `boot_disk.disk_id`, because older module versions created and attached their own disk instead.

Setting `enable-oslogin = "true"` only requests OS Login through instance metadata. The selected boot image must include a compatible guest agent; verify that support for the actual image family, image ID, or snapshot yourself. The module intentionally does not validate image support because arbitrary boot sources are valid inputs and metadata alone cannot prove guest availability.

## Usage

```hcl
module "compute_instance" {
  source = "./path-to-your-module"

  image_family              = "image"
  zone                      = "ru-central1-a"
  name                      = "name"
  hostname                  = "hostname"
  description               = "description"
  memory                    = 4
  gpus                      = 0
  cores                     = 2
  core_fraction             = 100
  serial_port_enable        = true
  allow_stopping_for_update = true
  monitoring                = true
  backup                    = false
  boot_disk = {
    size        = 30
    block_size  = 4096
    type        = "network-ssd"
    image_id    = null
    snapshot_id = null
  }
  secondary_disks = [
    {
      disk_id     = null
      auto_delete = true
      device_name = "secondary-disk"
      mode        = "READ_WRITE"
      size        = 100
      block_size  = 4096
      type        = "network-hdd"
    }
  ]
  filesystems = [
    {
      filesystem_id = null
      mode          = "READ_WRITE"
      zone          = "ru-central1-a"
    }
  ]

  # Authentication - either use OS Login
  enable_oslogin_or_ssh_keys = {
    enable-oslogin = "true"
  }
  
  # Or use SSH keys
  # enable_oslogin_or_ssh_keys = {
  #   ssh_user = "username"
  #   ssh_key  = "~/.ssh/id_rsa.pub"
  # }
  network_interfaces = [
    {
      subnet_id = yandex_vpc_subnet.sub_a.id
      ipv4      = true
      nat       = true

    },
    {
      subnet_id  = yandex_vpc_subnet.sub_a.id
      ipv4       = true
      nat        = false
      dns_record = []
    }
  ]

  static_ip = {
    description             = "Static IP for dev instance"
    network_interface_index = 0
    external_ipv4_address = {
      zone_id = "ru-central1-a"
    }
  }
}
```
 ## How to Configure Terraform for Yandex.Cloud

 1. Install [YC CLI](https://cloud.yandex.com/docs/cli/quickstart)
 2. Add environment variables for Terraform authentication in Yandex.Cloud

     ```bash
     export YC_TOKEN=$(yc iam create-token)
     export YC_CLOUD_ID=$(yc config get cloud-id)
     export YC_FOLDER_ID=$(yc config get folder-id)
     ```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | > 3.3 |
| <a name="requirement_yandex"></a> [yandex](#requirement\_yandex) | >= 0.216.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | 3.9.0 |
| <a name="provider_yandex"></a> [yandex](#provider\_yandex) | 0.225.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [random_string.unique_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [yandex_backup_policy_bindings.this](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/backup_policy_bindings) | resource |
| [yandex_backup_policy_bindings.this_backup_binding](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/backup_policy_bindings) | resource |
| [yandex_compute_disk.secondary](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_disk) | resource |
| [yandex_compute_disk.this](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_disk) | resource |
| [yandex_compute_filesystem.this](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_filesystem) | resource |
| [yandex_compute_instance.this](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_instance) | resource |
| [yandex_iam_service_account.sa_instance](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/iam_service_account) | resource |
| [yandex_resourcemanager_folder_iam_member.sa_backup](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_resourcemanager_folder_iam_member.sa_monitoring](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_vpc_address.static_ip](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_address) | resource |
| [yandex_backup_policy.this_backup_policy](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/data-sources/backup_policy) | data source |
| [yandex_client_config.client](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/data-sources/client_config) | data source |
| [yandex_compute_image.image](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/data-sources/compute_image) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_stopping_for_update"></a> [allow\_stopping\_for\_update](#input\_allow\_stopping\_for\_update) | If true, allows Terraform to stop the instance in order to update its properties. If you try to update a property that requires stopping the instance without setting this field, the update will fail. | `bool` | `false` | no |
| <a name="input_backup"></a> [backup](#input\_backup) | Enable Yandex Cloud backup. By default it installs the agent and, if service\_account\_id is not provided,<br/>creates a service account with backup.editor. Set install\_backup\_agent=false for a preinstalled agent.<br/>Use backup\_policy\_id to specify backup policy OR backup\_frequency to specify backup frequency from default policies. | `bool` | `false` | no |
| <a name="input_backup_frequency"></a> [backup\_frequency](#input\_backup\_frequency) | Name of the backup policy. Can be 'Default daily', 'Default weekly', 'Default monthly' or custom policy name. | `string` | `"Default daily"` | no |
| <a name="input_backup_policy_id"></a> [backup\_policy\_id](#input\_backup\_policy\_id) | ID of the backup policy to use for creating the backup. If not specified, the default backup frequency will be used. | `string` | `null` | no |
| <a name="input_boot_disk"></a> [boot\_disk](#input\_boot\_disk) | Configuration for the boot disk. The module creates a disk when create is true and disk\_id is null; otherwise it attaches the supplied disk without creating a duplicate. Set create=false when disk\_id is supplied by a resource whose ID is unknown during plan. | <pre>object({<br/>    create      = optional(bool, true)<br/>    auto_delete = optional(bool, true)<br/>    device_name = optional(string, "boot-disk")<br/>    mode        = optional(string, "READ_WRITE")<br/>    disk_id     = optional(string, null)<br/>    size        = optional(number, 30)<br/>    block_size  = optional(number, 4096)<br/>    type        = optional(string, "network-ssd")<br/>    image_id    = optional(string, null)<br/>    snapshot_id = optional(string, null)<br/>    kms_key_id  = optional(string, null)<br/>  })</pre> | `{}` | no |
| <a name="input_core_fraction"></a> [core\_fraction](#input\_core\_fraction) | CPU core fraction | `number` | `100` | no |
| <a name="input_cores"></a> [cores](#input\_cores) | Number of CPU cores | `number` | `2` | no |
| <a name="input_custom_metadata"></a> [custom\_metadata](#input\_custom\_metadata) | Additional instance metadata. Use user\_data instead of custom\_metadata["user-data"] when raw cloud-init is intentional.<br/>Example:<pre>custom_metadata = {<br/>  foo = "bar"<br/>}</pre> | `map(any)` | `{}` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the instance. | `string` | `""` | no |
| <a name="input_disk_placement_group_id"></a> [disk\_placement\_group\_id](#input\_disk\_placement\_group\_id) | Disk placement policy configuration. Used when disk type is network-ssd-nonreplicated. | `string` | `null` | no |
| <a name="input_enable_oslogin_or_ssh_keys"></a> [enable\_oslogin\_or\_ssh\_keys](#input\_enable\_oslogin\_or\_ssh\_keys) | Authentication configuration for the instance. You can either:<br/>1. Enable OS Login by setting enable-oslogin = "true"<br/>2. Provide an SSH public key by setting ssh\_user and exactly one of ssh\_key (path) or ssh\_public\_key (content)<br/><br/>Example for OS Login:<pre>enable_oslogin_or_ssh_keys = {<br/>  enable-oslogin = "true"<br/>}</pre>Example for SSH key content:<pre>enable_oslogin_or_ssh_keys = {<br/>  ssh_user       = "username"<br/>  ssh_public_key = "ssh-ed25519 AAAA... user@example"<br/>}</pre> | <pre>object({<br/>    enable-oslogin = optional(string, "false")<br/>    ssh_user       = optional(string)<br/>    ssh_key        = optional(string)<br/>    ssh_public_key = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_filesystems"></a> [filesystems](#input\_filesystems) | List of filesystems that are attached to the instance. Set create=false for a supplied filesystem\_id that is unknown during plan. | <pre>list(object({<br/>    create        = optional(bool, true)<br/>    filesystem_id = optional(string, null)<br/>    device_name   = optional(string, null)<br/>    mode          = optional(string, "READ_WRITE")<br/>    description   = optional(string, null)<br/>    zone          = optional(string, null)<br/>    size          = optional(number, 10)<br/>    block_size    = optional(number, 4096)<br/>    type          = optional(string, "network-ssd")<br/>  }))</pre> | `[]` | no |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | The ID of the folder that the resource belongs to. If it is not provided, the default provider folder is used. | `string` | `null` | no |
| <a name="input_gpu_cluster_id"></a> [gpu\_cluster\_id](#input\_gpu\_cluster\_id) | ID of the GPU cluster to attach this instance to. The GPU cluster must exist in the same zone as the instance. | `string` | `""` | no |
| <a name="input_gpus"></a> [gpus](#input\_gpus) | Number of GPUs. Use variable 'platform\_id' with GPUs support. Actual available options: https://yandex.cloud/ru/docs/compute/concepts/vm-platforms#gpu-platforms. | `number` | `0` | no |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | Host name for the instance. This field is used to generate the instance fqdn value. The host name must be unique within the network and region. If not specified, the host name will be equal to id of the instance and fqdn will be <id>.auto.internal. Otherwise FQDN will be <hostname>.<region\_id>.internal. | `string` | `""` | no |
| <a name="input_image_family"></a> [image\_family](#input\_image\_family) | The source image family to use for disk creation. command: yc compute image list --folder-id standard-images | `string` | `null` | no |
| <a name="input_install_backup_agent"></a> [install\_backup\_agent](#input\_install\_backup\_agent) | Whether to install the backup agent through generated cloud-init. Null preserves the backup legacy flag. | `bool` | `null` | no |
| <a name="input_install_monitoring_agent"></a> [install\_monitoring\_agent](#input\_install\_monitoring\_agent) | Whether to install the monitoring agent through generated cloud-init. Null preserves the monitoring legacy flag. | `bool` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | A set of key/value label pairs to assign to the instance. | `map(string)` | `{}` | no |
| <a name="input_maintenance_grace_period"></a> [maintenance\_grace\_period](#input\_maintenance\_grace\_period) | Time between notification via metadata service and maintenance. E.g., 60s. | `string` | `""` | no |
| <a name="input_maintenance_policy"></a> [maintenance\_policy](#input\_maintenance\_policy) | Behaviour on maintenance events. The default is unspecified. Values: unspecified, migrate, restart. | `string` | `"unspecified"` | no |
| <a name="input_manage_service_account_iam"></a> [manage\_service\_account\_iam](#input\_manage\_service\_account\_iam) | Whether the module manages monitoring and backup IAM roles. Null manages roles for a module-created service account only; external service accounts require true. | `bool` | `null` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory size | `number` | `4` | no |
| <a name="input_monitoring"></a> [monitoring](#input\_monitoring) | Enable Yandex Cloud monitoring integration. By default it installs the agent and, if service\_account\_id is not provided,<br/>creates a service account with monitoring.editor. Set install\_monitoring\_agent=false for a preinstalled agent.<br/><br/>Note: The UI won't show the 'Monitoring enabled' checkbox, but monitoring will work. | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Resource name. Required parameter. | `string` | n/a | yes |
| <a name="input_network_acceleration_type"></a> [network\_acceleration\_type](#input\_network\_acceleration\_type) | Type of network acceleration. The default is standard. Values: standard, software\_accelerated. | `string` | `"standard"` | no |
| <a name="input_network_interfaces"></a> [network\_interfaces](#input\_network\_interfaces) | List of network interfaces for the instance. At least one network interface must be specified.<br/><br/>Example with NAT:<pre>network_interfaces = [<br/>  {<br/>    subnet_id = "your-subnet-id"<br/>    nat       = true<br/>  }<br/>]</pre>Example with multiple interfaces:<pre>network_interfaces = [<br/>  {<br/>    subnet_id = "your-subnet-id-1"<br/>    nat       = true<br/>  },<br/>  {<br/>    subnet_id = "your-subnet-id-2"<br/>    nat       = false<br/>  }<br/>]</pre> | <pre>list(object({<br/>    subnet_id          = string<br/>    index              = optional(number)<br/>    ipv4               = optional(bool, true)<br/>    ip_address         = optional(string)<br/>    nat                = optional(bool, false)<br/>    nat_ip_address     = optional(string)<br/>    security_group_ids = optional(list(string))<br/>    dns_record = optional(list(object({<br/>      fqdn        = string<br/>      dns_zone_id = optional(string)<br/>      ttl         = optional(number)<br/>      ptr         = optional(bool, false)<br/>    })), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_placement_policy"></a> [placement\_policy](#input\_placement\_policy) | Placement policy configuration for the instance. Controls how the instance is placed within dedicated host groups.<br/><br/>Example:<pre>placement_policy = {<br/>  placement_group_id = "your-placement-group-id"<br/>  host_affinity_rules = [<br/>    {<br/>      key    = "host"<br/>      op     = "IN"<br/>      values = ["host-1", "host-2"]<br/>    }<br/>  ]<br/>}</pre> | <pre>object({<br/>    placement_group_id = optional(string)<br/>    host_affinity_rules = optional(list(object({<br/>      key    = string<br/>      op     = string<br/>      values = list(string)<br/>    })), [])<br/>  })</pre> | `{}` | no |
| <a name="input_platform_id"></a> [platform\_id](#input\_platform\_id) | The type of compute platform. Actual available options: https://yandex.cloud/ru/docs/compute/concepts/vm-platforms. | `string` | `"standard-v3"` | no |
| <a name="input_scheduling_policy_preemptible"></a> [scheduling\_policy\_preemptible](#input\_scheduling\_policy\_preemptible) | Specifies if the instance is preemptible. Defaults to false. | `bool` | `false` | no |
| <a name="input_secondary_disks"></a> [secondary\_disks](#input\_secondary\_disks) | List of secondary disks. Set create=false for a supplied disk\_id that is unknown during plan. | <pre>list(object({<br/>    create      = optional(bool, true)<br/>    index       = optional(number)<br/>    disk_id     = optional(string)<br/>    auto_delete = optional(bool, true)<br/>    device_name = optional(string, "secondary-disk")<br/>    mode        = optional(string, "READ_WRITE")<br/>    size        = optional(number, 50)<br/>    block_size  = optional(number, 4096)<br/>    type        = optional(string, "network-hdd")<br/>    description = optional(string, "Secondary disk")<br/>    kms_key_id  = optional(string, null)<br/>  }))</pre> | `[]` | no |
| <a name="input_serial_port_enable"></a> [serial\_port\_enable](#input\_serial\_port\_enable) | Enable serial port | `bool` | `false` | no |
| <a name="input_service_account_id"></a> [service\_account\_id](#input\_service\_account\_id) | Optional service account ID | `string` | `null` | no |
| <a name="input_static_ip"></a> [static\_ip](#input\_static\_ip) | Configuration for a module-managed external static IP address. Set network\_interface\_index when more than one eligible NAT interface exists. | <pre>object({<br/>    description             = optional(string)<br/>    folder_id               = optional(string)<br/>    labels                  = optional(map(string))<br/>    deletion_protection     = optional(bool)<br/>    network_interface_index = optional(number)<br/>    external_ipv4_address = optional(object({<br/>      zone_id                  = string<br/>      ddos_protection_provider = optional(string)<br/>      outgoing_smtp_capability = optional(string)<br/>    }))<br/>    dns_record = optional(object({<br/>      fqdn        = string<br/>      dns_zone_id = string<br/>      ttl         = optional(number)<br/>      ptr         = optional(bool)<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | Raw cloud-init user-data. When set, it is used unchanged and takes precedence over generated SSH and agent configuration. | `string` | `null` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | The availability zone where the virtual machine will be created. If it is not provided, the default provider zone is used. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_attached_boot_disk"></a> [attached\_boot\_disk](#output\_attached\_boot\_disk) | Full boot disk attachment object. |
| <a name="output_attached_filesystems"></a> [attached\_filesystems](#output\_attached\_filesystems) | Full filesystem attachment objects. |
| <a name="output_attached_secondary_disks"></a> [attached\_secondary\_disks](#output\_attached\_secondary\_disks) | Full secondary disk attachment objects. |
| <a name="output_boot_disk_id"></a> [boot\_disk\_id](#output\_boot\_disk\_id) | The ID of the boot disk |
| <a name="output_external_ip"></a> [external\_ip](#output\_external\_ip) | The external IP address of the instance |
| <a name="output_filesystem_ids"></a> [filesystem\_ids](#output\_filesystem\_ids) | The list of filesystem IDs |
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | The fully qualified DNS name of this instance |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | The ID of the instance |
| <a name="output_instance_id_scalar"></a> [instance\_id\_scalar](#output\_instance\_id\_scalar) | The ID of the instance as a scalar value. |
| <a name="output_internal_ip"></a> [internal\_ip](#output\_internal\_ip) | The internal IP address of the instance |
| <a name="output_network_interfaces"></a> [network\_interfaces](#output\_network\_interfaces) | Full network interface objects attached to the instance. |
| <a name="output_secondary_disk_ids"></a> [secondary\_disk\_ids](#output\_secondary\_disk\_ids) | The list of secondary disk IDs |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
