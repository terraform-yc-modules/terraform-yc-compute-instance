# Compute Instance Terraform Module for Yandex.Cloud

 ## Features

- **Compute Instance**: Create a Yandex.Cloud compute instance with customizable resources.
- **Disks**: Attach multiple disks, including boot and secondary disks, with custom settings.
- **Network Interfaces**: Configure multiple network interfaces with options for NAT, static IP, and DNS records.
- **Static IP**: Optionally assign a static IP to the instance.
- **Filesystem**: Attach a Yandex.Cloud Filesystem to the instance.
- **Monitoring and Backup**: Enable monitoring and backup services using Yandex.Cloud's predefined scripts.
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
      zone          = ru-central1-a"
    }
  ]

  enable_oslogin_or_ssh_keys = {
    enable-oslogin = "true"
    ssh_key        = null
    ssh_user       = null
  }
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
    name        = "my-static-ip"
    description = "Static IP for dev instance"
    external_ipv4_address = {
      zone_id = Эru-central1-a"
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

 ## Requirements

 | Name       | Version |
 |------------|---------|
 | terraform  | >= 1.0.0 |
 | yandex     | >= 0.101.0 |
 | random     | > 3  |

 ## Providers

 | Name   | Version |
 |--------|---------|
 | yandex | 0.122.0 |

 ## Resources

 | Name                           | Type    |
 |--------------------------------|---------|
 | yandex_compute_instance.this   | resource |

## Inputs

| Name                      | Description                                                                                  | Type                      | Default | Required |
|---------------------------|----------------------------------------------------------------------------------------------|---------------------------|---------|:--------:|
| name                      | Resource name.                                                                               | `string`                  | `null`  |    no    |
| description               | Description of the instance.                                                                 | `string`                  | `null`  |    no    |
| folder_id                 | The ID of the folder that the resource belongs to.                                            | `string`                  | `null`  |    no    |
| zone                      | The availability zone where the virtual machine will be created.                             | `string`                  | `null`  |    no    |
| labels                    | A set of key/value label pairs to assign to the instance.                                    | `map(string)`             | `{}`    |    no    |
| metadata                  | Metadata key/value pairs to make available from within the instance.                         | `map(string)`             | `{}`    |    no    |
| network_interface         | Networks to attach to the instance. This can be specified multiple times.                    | `list(object)`            | n/a     |   yes    |
| resources                 | Compute resources allocated for the instance. The structure is documented below.             | `object`                  | n/a     |   yes    |
| boot_disk                 | The boot disk for the instance. The structure is documented below.                           | `object`                  | n/a     |   yes    |
| secondary_disks           | A list of secondary disks to attach to the instance. The structure is documented below.      | `list(object)`            | `[]`    |    no    |
| filesystem                | A list of filesystems to attach to the instance. The structure is documented below.          | `list(object)`            | `[]`    |    no    |
| service_account_id        | ID of the service account authorized for this instance.                                      | `string`                  | `null`  |    no    |
| enable_oslogin_or_ssh_keys| OS Login or SSH key configuration.                                                           | `object`                    | n/a |    no    |
## Boot Disk

| Name                      | Description                                                                                  | Type                      | Default | Required |
|---------------------------|----------------------------------------------------------------------------------------------|---------------------------|---------|:--------:|
| auto_delete               | Determines if the disk should be automatically deleted when the instance is deleted.         | `string`                  | true  |    no    |
| device_name               | Name of the boot disk device.                                                                | `string`                  | `null`  |    no    |
| mode                      | Access mode for the boot disk (READ_WRITE or READ_ONLY).                                     | `string`                  | "READ_WRITE"  |    no    |
| disk_id                   | ID of an existing disk to attach as the boot disk.                                           | `string`                  | `null`  |    no    |
| size                      | Size of the boot disk in GB. Must be between 4 and 8192 if specified.                        | `number`                  | 30    |    no    |
| block_size                | Block size of the disk in bytes. Must be one of 4096, 8192, 16384, 32768, 65536, 131072.     | `number`                  | 4096    |    no    |
| type                      | Disk type (network-hdd, network-ssd, network-ssd-nonreplicated, network-ssd-io-m3).          | `string`                  | "network-hdd"    |   yes    |
| snapshot_id               | Compute resources allocated for the instance. The structure is documented below.             | `string`                  | `null`    |   yes    |
| image_id                  | ID of the disk image to use for creating the boot disk.                                      | `string`                  | `null`    |   yes    |

### Secondary Disks

| Name           | Description                                     | Type     | Default | Required |
|----------------|-------------------------------------------------|----------|---------|:--------:|
| device_name    | Name of the device for the disk attachment.      | `string` | `null`  |    no    |
| size                      | Size of the boot disk in GB. Must be between 4 and 8192 if specified.                        | `number`                  | 30    |    no    |
| block_size                | Block size of the disk in bytes. Must be one of 4096, 8192, 16384, 32768, 65536, 131072.     | `number`                  | 4096    |    no    |
| type                      | Disk type (network-hdd, network-ssd, network-ssd-nonreplicated, network-ssd-io-m3).          | `string`                  | "network-hdd"    |   yes    |

### Filesystem

| Name           | Description                                      | Type     | Default | Required |
|----------------|--------------------------------------------------|----------|---------|:--------:|
| filesystem_id  | ID of the filesystem to attach.                  | `string` | n/a     |   yes    |
| device_name    | Name of the device for the filesystem attachment.| `string` | `null`  |    no    |
| mode           | Access mode (`READ_ONLY`, `READ_WRITE`).         | `string` | `null`  |    no    |


## Outputs

| Name                              | Description                                           |
|----------------------------------- |------------------------------------------------------|
| fqdn                              | The fully qualified DNS name of this instance.        |
| network_interface.0.ip_address     | The internal IP address of the instance.              |
| network_interface.0.nat_ip_address | The external IP address of the instance.              |
| instance_id                       | The ID of the instance.                               |
| disks_ids                         | The list of attached disk IDs.                        |
