# Migration notes

## Managed static IP

`static_ip` now attaches its managed address to one NAT interface instead of silently leaving the allocation unused. If exactly one NAT interface has no explicit `nat_ip_address`, that interface remains the implicit choice. With multiple eligible NAT interfaces, set `static_ip.network_interface_index` to the zero-based position in `network_interfaces`.

An explicit `network_interfaces[*].nat_ip_address` always has precedence. Do not combine it with a managed `static_ip` on the same interface: remove the unused `static_ip` object or select a different NAT interface. This correction can replace an ephemeral public IP with the reserved address on the next apply; review the plan and update dependent DNS/allowlists first.

`static_ip.folder_id` and `static_ip.labels` are now honored when explicitly set. Omitting them retains the legacy module folder and instance labels.

## Existing boot disks and legacy orphan disks

The module now honors `boot_disk.disk_id` and does not create `yandex_compute_disk.this` in that case. Existing module-created boot disks move automatically from `yandex_compute_disk.this` to `yandex_compute_disk.this[0]` when the module continues to create the boot disk.

Older versions ignored `boot_disk.disk_id`: they created and attached a module disk instead. Therefore switching an existing deployment to `boot_disk.disk_id` is **not** a no-op migration. It can detach or replace the current boot source, and the old module-created disk may be a still-attached boot disk rather than an unused orphan.

Before changing this input, inventory actual attachments and IDs, make a backup or snapshot, and review the saved plan. If an old module-created disk is truly an unused orphan, transfer ownership to a dedicated configuration (for example, import it there) or intentionally leave it unmanaged before removing it from this module's state:

```shell
terraform state show 'module.instance.yandex_compute_disk.this'
terraform state rm 'module.instance.yandex_compute_disk.this'
```

Run `state rm` only after the ownership handoff and ID verification. It removes Terraform ownership, not the cloud disk. Do not use it to make an attached boot disk disappear from state; first choose and verify the replacement/retention strategy.

External secondary disks and filesystems are now attached without a module-created duplicate. Their original list indexes remain the attachment and generated-resource keys.

Known `boot_disk.disk_id`, `secondary_disks[*].disk_id`, and `filesystems[*].filesystem_id` values retain this automatic no-create behavior. When the ID comes from a resource in the same plan and is therefore unknown during planning, set `create = false` on that storage object. This explicitly keeps it external, skips the boot-image lookup for an external boot disk, and allows the instance attachment to keep the unknown ID until apply.

## Metadata and agents

`user_data` is raw authoritative cloud-init content. When set, the module does not append SSH users or agent installation commands. Use either `user_data` or `custom_metadata["user-data"]`, not both. `ssh_public_key` in `enable_oslogin_or_ssh_keys` accepts key content; the existing `ssh_key` path remains supported and preserves legacy generated metadata when new inputs are absent.

`install_monitoring_agent` and `install_backup_agent` are nullable: `null` retains the legacy `monitoring`/`backup` behavior. Set `false` when an agent is preinstalled. `manage_service_account_iam` is also nullable: internal service accounts retain legacy role management, while external service-account roles require explicit `true`. Legacy service flags can still provision roles for a preinstalled agent.

## OS Login guest-agent support

`enable-oslogin = "true"` writes the OS Login metadata request only. It does not install or validate a guest agent. Verify guest-agent support for the actual boot image, whether it comes from `image_family`, an explicit `image_id`, or a snapshot. No Terraform precondition is added because the module supports arbitrary boot sources and metadata cannot prove that the guest can honor the request.
