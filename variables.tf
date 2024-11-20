variable "name" {
  description = "Resource name."
  type        = string
}

variable "platform_id" {
  description = "The type of virtual machine to create. The default is 'standard-v1'."
  type        = string
  default     = "standard-v3"
}

variable "zone" {
  description = "The availability zone where the virtual machine will be created. If it is not provided, the default provider folder is used."
  type        = string
}

variable "description" {
  description = "Description of the instance."
  type        = string
  default     = ""
}

variable "memory" {
  description = "Memory size"
  type        = number
  default     = 4
}

variable "gpus" {
  description = "Number of GPUs"
  type        = number
  default     = 0
}

variable "cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "core_fraction" {
  description = "CPU core fraction"
  type        = number
  default     = 100
}

variable "hostname" {
  description = "Host name for the instance. This field is used to generate the instance fqdn value. The host name must be unique within the network and region. If not specified, the host name will be equal to id of the instance and fqdn will be <id>.auto.internal. Otherwise FQDN will be <hostname>.<region_id>.internal."
  type        = string
  default     = ""
}


variable "network_interfaces" {
  description = "List of network interfaces"
  type = list(object({
    subnet_id          = string
    index              = optional(number)
    ipv4               = optional(bool, true)
    ip_address         = optional(string)
    nat                = optional(bool, false)
    nat_ip_address     = optional(string)
    security_group_ids = optional(list(string))
    dns_record = optional(list(object({
      fqdn        = string
      dns_zone_id = optional(string)
      ttl         = optional(number)
      ptr         = optional(bool, false)
    })), [])
  }))
  default = [
    {
      subnet_id          = null
      index              = null
      ipv4               = true
      ip_address         = null
      nat                = false
      nat_ip_address     = null
      security_group_ids = null
      dns_record         = []
    }
  ]
}
variable "static_ip" {
  description = "Configuration for static IP address"
  type = object({
    description         = optional(string)
    folder_id           = optional(string)
    labels              = optional(map(string))
    deletion_protection = optional(bool)
    external_ipv4_address = optional(object({
      zone_id                  = string
      ddos_protection_provider = optional(string)
      outgoing_smtp_capability = optional(string)
    }))
    dns_record = optional(object({
      fqdn        = string
      dns_zone_id = string
      ttl         = optional(number)
      ptr         = optional(bool)
    }))
  })
  default = null
}



variable "image_family" {
  description = "The source image family to use for disk creation. command: yc compute image list --folder-id standard-images"
  type        = string
  default     = null
}

variable "disk_placement_policy" {
  description = "Disk placement policy configuration"
  type = object({
    disk_placement_group_id = string
  })
  default = null
}

variable "folder_id" {
  description = "The ID of the folder that the resource belongs to. If it is not provided, the default provider folder is used."
  type        = string
  default     = null
}

variable "boot_disk" {
  description = "Configuration for the boot disk"
  type = object({
    auto_delete = optional(bool, true)
    device_name = optional(string, "boot-disk")
    mode        = optional(string, "READ_WRITE")
    disk_id     = optional(string, null)
    size        = optional(number, 30)
    block_size  = optional(number, 4096)
    type        = optional(string, "network-hdd")
    image_id    = optional(string, null)
    snapshot_id = optional(string, null)
  })
  default = {}

  validation {
    condition = (
      var.boot_disk.size == null || (var.boot_disk.size >= 4 && var.boot_disk.size <= 8192)
      ) && (
      var.boot_disk.block_size == null || contains([4096, 8192], var.boot_disk.block_size)
      ) && (
      var.boot_disk.type == null || contains(["network-hdd", "network-ssd", "network-ssd-nonreplicated", "network-ssd-io-m3"], var.boot_disk.type)
      ) && (
      var.boot_disk.mode == null || contains(["READ_WRITE", "READ_ONLY"], var.boot_disk.mode)
    )
    error_message = <<EOT
Validation failed for boot_disk:
- size must be in range [4, 8192] GB if specified.
- block size must be one of 4096, 8192, 16384, 32768, 65536, 131072.
- type must be one of 'network-hdd', 'network-ssd', or 'network-ssd-nonreplicated' if specified.
- mode must be either 'READ_WRITE' or 'READ_ONLY' if specified.
EOT
  }
}



variable "labels" {
  description = "A set of key/value label pairs to assign to the instance."
  type        = map(string)
  default     = {}
}

variable "enable_oslogin_or_ssh_keys" {
  description = "Enabling OS Login or adding ssh-keys to metadata of node-groups."
  type        = map(any)
  default = {
    enable-oslogin = "false"
    ssh_user       = null
    ssh_key        = null
  }
  validation {
    condition = contains(["true", "false"], var.enable_oslogin_or_ssh_keys.enable-oslogin) && ((var.enable_oslogin_or_ssh_keys.enable-oslogin == "true" && var.enable_oslogin_or_ssh_keys.ssh_user == null && var.enable_oslogin_or_ssh_keys.ssh_key == null) ||
    (var.enable_oslogin_or_ssh_keys.enable-oslogin == "false" && var.enable_oslogin_or_ssh_keys.ssh_user != null && var.enable_oslogin_or_ssh_keys.ssh_key != null))
    error_message = "Either OS Login should be enabled or SSH keys (ssh_user and ssh_key) should be provided."
  }
}
variable "custom_metadata" {
  description = <<-EOF
     Adding custom metadata to node-groups.
     Example:
     ```
     custom_metadata = {
       foo = "bar"
     }
     ```
   EOF
  type        = map(any)
  default     = {}
}
variable "serial_port_enable" {
  description = "Enable serial port"
  type        = bool
  default     = false
}
variable "allow_stopping_for_update" {
  description = "If true, allows Terraform to stop the instance in order to update its properties. If you try to update a property that requires stopping the instance without setting this field, the update will fail."
  type        = bool
  default     = false
}

variable "network_acceleration_type" {
  description = "Type of network acceleration. The default is standard. Values: standard, software_accelerated."
  type        = string
  default     = "standard"
}

variable "gpu_cluster_id" {
  description = "ID of the GPU cluster to attach this instance to. The GPU cluster must exist in the same zone as the instance."
  type        = string
  default     = ""
}

variable "maintenance_policy" {
  description = "Behaviour on maintenance events. The default is unspecified. Values: unspecified, migrate, restart."
  type        = string
  default     = "unspecified"
}

variable "maintenance_grace_period" {
  description = "Time between notification via metadata service and maintenance. E.g., 60s."
  type        = string
  default     = ""
}

variable "scheduling_policy_preemptible" {
  description = "Specifies if the instance is preemptible. Defaults to false."
  type        = bool
  default     = false
}

variable "placement_policy" {
  description = "Placement policy configuration"
  type = object({
    placement_group_id = string
    host_affinity_rules = list(object({
      key    = string
      op     = string
      values = list(string)
    }))
  })
  default = {
    placement_group_id  = null
    host_affinity_rules = []
  }
}


variable "service_account_id" {
  description = "Optional service account ID"
  type        = string
  default     = null
}

variable "monitoring" {
  description = "Flag to create a new service account if service_account_id is not provided. UI will't show checkbox 'Monitoring enabled' but will works"
  type        = bool
  default     = false
}

resource "random_string" "unique_id" {
  length  = 8
  upper   = false
  lower   = true
  numeric = true
  special = false
}


variable "backup" {
  description = "Flag to create a new service account if service_account_id is not provided"
  type        = bool
  default     = false
}

variable "filesystems" {
  description = "List of filesystems that are attached to the instance."
  type = list(object({
    filesystem_id = optional(string, null)
    device_name   = optional(string, null)
    mode          = optional(string, "READ_WRITE")
    description   = optional(string, null)
    zone          = optional(string, null)
    size          = optional(number, 10)
    block_size    = optional(number, 4096)
    type          = optional(string, "network-ssd")
  }))
  default = []
}


variable "secondary_disks" {
  description = "List of secondary disks"
  type = list(object({
    index       = optional(number)
    disk_id     = optional(string)
    auto_delete = optional(bool, true)
    device_name = optional(string, "secondary-disk")
    mode        = optional(string, "READ_WRITE")
    size        = optional(number, 100)
    block_size  = optional(number, 4096)
    type        = optional(string, "network-hdd")
    description = optional(string, "Secondary disk")
  }))
  default = []
}

variable "backup_frequency" {
  description = "Timing of backups: Default daily,  Default weekly, Default monthly"
  type        = string
  default     = "Default daily"
}
