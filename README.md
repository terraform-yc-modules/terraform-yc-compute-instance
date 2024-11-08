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

  name               = "my-instance"
  platform_id        = "standard-v1"
  zone               = "ru-central1-a"
  cores              = 2
  memory             = 4
  boot_disk_size     = 30
  network_interfaces = [
    {
      subnet_id = "your-subnet-id"
      nat       = true
    }
  ]
  
  static_ip = {
    description = "Static IP for my instance"
    external_ipv4_address = {
      zone_id = "ru-central1-a"
    }
  }

  monitoring = true
  backup     = true

  enable_oslogin_or_ssh_keys = {
    enable-oslogin = "false"
    ssh-keys       = "user:ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAr..."
  }
  
  filesystems = [
    {
      filesystem_id = "your-filesystem-id"
    }
  ]

  secondary_disks = [
    {
      disk_id     = "your-disk-id"
      auto_delete = true
      device_name = "secondary-disk-1"
      mode        = "READ_WRITE"
    }
  ]
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
| allow_stopping_for_update | If true, allows Terraform to stop the instance in order to update its properties.            | `bool`                    | `false` |    no    |

### Secondary Disks

| Name           | Description                                     | Type     | Default | Required |
|----------------|-------------------------------------------------|----------|---------|:--------:|
| device_name    | Name of the device for the disk attachment.      | `string` | `null`  |    no    |
| mode           | Access mode (`READ_ONLY`, `READ_WRITE`).         | `string` | `null`  |    no    |

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
