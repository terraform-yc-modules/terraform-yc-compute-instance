# Provider 0.225 Modernization Design

## Goal

Modernize the compute-instance module against Yandex Provider 0.225.0 while preserving existing inputs, defaults, Terraform resource addresses, and state compatibility.

## Compatibility contract

- Base all work on `origin/main`, including its `nat_ip_address` fix and `yandex >= 0.136.0` constraint.
- Keep all existing public inputs and defaults compatible.
- Keep every existing resource and data-source address unchanged.
- Make every newly exposed capability opt-in.
- Raise the provider minimum to the earliest release that supports every statically referenced schema field; verify `0.216.0` as the candidate floor. Do not introduce an upper bound or commit a lock file.
- Do not add Terraform test files.

## Module changes

Expose the following `yandex_compute_instance` capabilities:

- `allow_recreate` as an optional boolean defaulting to `false`.
- `reserved_instance_pool_id` as an optional nullable string.
- `metadata_options` with GCE, AWS v1, and AWS v2 endpoint/token values limited to integers from 0 through 2.
- `local_disks` with required `size_bytes` and optional `kms_key_id`.
- `placement_group_partition` inside the existing `placement_policy` object.
- IPv6 allocation and address fields plus IPv6 and NAT DNS record lists inside each existing network-interface object.

Expose `allow_recreate` and the provider's mutually exclusive `hardware_generation` variants for the boot and module-created secondary disks. Do not expose read-only instance hardware-generation data as an input.

Add provider-backed validation for finite enums and new numeric ranges where it can be expressed without rejecting configurations previously accepted by the module. Do not tighten legacy inputs unless necessary to make a newly added field safe.

Do not add `internal_ipv4_address` to the existing `static_ip` input: that object currently represents an external NAT address and changing its ownership semantics would broaden the design and smoke-test surface.

## Provider and state considerations

Terraform validates resource arguments and dynamic-block content against the selected provider schema even when their runtime values are null or their `for_each` collections are empty. The module therefore cannot retain `>= 0.136.0` while statically referencing fields introduced later. Set the minimum to the earliest release that validates the complete module, expected to be `>= 0.216.0` because `reserved_instance_pool_id` was introduced there, and prove that boundary directly. Cloud smoke testing selects 0.225.0 explicitly in the disposable test configuration.

The provider migrated `yandex_compute_filesystem` to Terraform Plugin Framework and includes a state upgrader. The module retains `yandex_compute_filesystem.this` and its `for_each` keys unchanged, so no module-level `moved` block or state command is required.

## Documentation and example

Extend `examples/example-1-all-configurations` to exercise safe new capabilities supported in a general default-folder smoke test. Keep unavailable or allocation-dependent features such as local disks and reserved instance pools documented but disabled by default. Regenerate the existing README terraform-docs section without duplicating markers.

## Verification

Run recursive formatting checks, initialization with provider 0.225.0 in an isolated smoke workspace, validation, available repository lint/pre-commit checks, and `git diff --check`. Inspect plans for both legacy-compatible defaults and the comprehensive example.

For the cloud smoke test, use the comprehensive example in the user's configured default folder with unique names and the smallest supported CPU, memory, and disk preset. Show the saved plan and exact resource scope before apply. After apply verification, create a saved destroy plan, destroy all disposable resources, and confirm both empty state and an empty destroy plan.

Push and PR creation require separate approval after the verified diff is presented.
