# Mixed external storage fixture

This disposable fixture creates its own external boot disk, secondary disk, and filesystem, then passes them together with module-created secondary storage and filesystem entries. The fixture sets `create = false` for its externally supplied storage because their IDs are unknown until apply; this keeps resource ownership outside the module during planning. The externally supplied disks use `auto_delete = false` so a cloud scenario can verify ownership and cleanup deliberately.

`user_data` writes `/var/tmp/module-refactor-marker` for guest-side cloud-init verification. Set a unique `name_prefix` for every cloud run.
