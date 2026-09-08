# Provider 0.225 Modernization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the compatible Yandex Compute capabilities identified in the 0.136.0-to-0.225.0 schema audit and verify them without changing existing callers or state addresses.

**Architecture:** Extend the existing typed objects and pass their optional values into the current resources and dynamic blocks. Keep documentation and smoke-example work separate from module implementation so each change has a focused review boundary.

**Tech Stack:** Terraform HCL, Yandex Cloud Provider 0.225.0, terraform-docs, pre-commit/TFLint.

**Spec:** `docs/superpowers/specs/2026-09-08-provider-0225-modernization-design.md`

## Global Constraints

- Preserve all existing inputs, defaults, resource addresses, `for_each` keys, and state ownership.
- New provider capabilities must be opt-in.
- Keep the reusable module provider constraint at `>= 0.136.0`; select 0.225.0 only in disposable verification configuration.
- Do not add Terraform test files or commit `.terraform.lock.hcl`.
- Do not apply, destroy, push, or create a PR from an implementation-agent task.

---

### Task 1: Extend module inputs and resource mappings

**Files:**
- Modify: `variables.tf`
- Modify: `main.tf`
- Modify: `storages.tf`

**Interfaces:**
- Consumes: existing `network_interfaces`, `placement_policy`, `boot_disk`, and `secondary_disks` objects.
- Produces: optional `allow_recreate`, `reserved_instance_pool_id`, `metadata_options`, `local_disks`, disk `hardware_generation`, IPv6/DNS fields, and placement partition mappings.

- [ ] **Step 1: Record the current baseline**

Run `terraform fmt -check -recursive` and record whether failures pre-exist. Do not modify unrelated formatting.

- [ ] **Step 2: Add compatible typed inputs**

Add the exact opt-in fields from the design. Represent hardware generation as an optional object containing mutually exclusive `legacy_features` and `generation2_features`; validate that at most one is configured. Validate metadata-option values as integers in `[0, 2]` and preserve null when the block is omitted.

- [ ] **Step 3: Map instance fields**

Pass scalar fields directly, add conditional dynamic blocks for `metadata_options` and `local_disk`, extend `network_interface` with IPv6 plus IPv6/NAT DNS records, and pass `placement_group_partition` without changing existing block presence or addresses.

- [ ] **Step 4: Map disk fields**

Pass `allow_recreate` and generate the provider `hardware_generation` block for `yandex_compute_disk.this` and every module-created `yandex_compute_disk.secondary` instance. Preserve the existing numeric `for_each` keys.

- [ ] **Step 5: Verify module syntax and compatibility**

Run `terraform fmt -check -recursive`, `terraform validate` after initialization is available, and `git diff --check`. Inspect the diff specifically for changed defaults, changed resource labels, or changed collection identities.

- [ ] **Step 6: Commit the focused implementation**

Commit only `variables.tf`, `main.tf`, and `storages.tf` with message `feat: expose current compute instance capabilities`.

### Task 2: Update comprehensive example and documentation

**Files:**
- Modify: `examples/example-1-all-configurations/main.tf`
- Modify: `examples/example-1-all-configurations/variables.tf` only if needed for unique smoke naming or small resource presets
- Modify: `examples/example-1-all-configurations/versions.tf`
- Modify: `README.md`

**Interfaces:**
- Consumes: the public inputs produced by Task 1.
- Produces: a comprehensive but default-folder-safe example and accurate generated module documentation.

- [ ] **Step 1: Select safe example coverage**

Exercise `allow_recreate`, `metadata_options` including AWS v2, placement partition only when no external placement-group dependency is required, and safe IPv6/DNS fields only when the example network supports them. Document but do not enable local disks or reserved-instance pools because availability/allocation is account-dependent.

- [ ] **Step 2: Pin the root example verification release**

Set the comprehensive example's Yandex provider constraint to `= 0.225.0`. Do not change the reusable root module minimum constraint.

- [ ] **Step 3: Make disposable naming configurable**

Replace fixed cloud resource names with a single optional name-prefix input where necessary so the controller can pass a unique smoke identifier without changing module defaults.

- [ ] **Step 4: Update generated documentation**

Identify the existing terraform-docs markers/configuration and regenerate the current README section. Add concise prose for account-dependent capabilities and the provider-0.225.0 tested version; do not duplicate generated sections.

- [ ] **Step 5: Verify example and documentation**

Run formatting checks, initialize and validate the comprehensive example, and run `git diff --check`. Confirm the example uses no explicit `folder_id`, creates no cloud folder, and does not reference existing mutable resources.

- [ ] **Step 6: Commit the focused documentation change**

Commit only the example and README changes with message `docs: cover provider 0.225 compute options`.

### Task 3: Integrate, review, and prepare cloud verification

**Files:**
- Review: all files changed since `origin/main`
- Temporary only: isolated smoke workspace and ignored Terraform artifacts

**Interfaces:**
- Consumes: Tasks 1 and 2 commits.
- Produces: review findings, local verification evidence, and a saved cloud plan whose exact scope can be shown for approval.

- [ ] **Step 1: Audit the full diff against the design**

Check every requested capability, all null/default paths, resource addresses, and `for_each` identities. Confirm no unrelated refactor entered the branch.

- [ ] **Step 2: Run the complete local verification set**

Run `terraform fmt -check -recursive`, root and comprehensive-example `terraform init`/`validate` with provider 0.225.0 selected for the example, repository pre-commit/TFLint checks when installed, and `git diff --check`.

- [ ] **Step 3: Prepare isolated cloud smoke inputs**

Use the comprehensive example, the default provider folder, a unique prefix, and the smallest supported CPU/memory/disk values. Do not create a cloud folder. Confirm planned IAM members affect only the disposable service account and note that `folder_iam_member` is additive.

- [ ] **Step 4: Create and inspect a saved plan**

Create a saved plan without applying it. Report every resource action and any external/static IP, IAM, backup, filesystem, or DNS side effect. Stop before apply for user approval.

- [ ] **Step 5: Apply, verify, and clean up after approval**

After explicit approval, apply the saved plan, verify the intended settings through Terraform state/provider reads, save a destroy plan, destroy all created resources, confirm empty state, and run an additional destroy plan that reports no changes.

- [ ] **Step 6: Prepare PR handoff**

Report branch, commits, files, provider range, verification evidence, state/migration caveats, and cloud cleanup. Stop for explicit push/PR approval.
