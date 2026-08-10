# Azure Virtual Machine

A single Linux VM with its own virtual network, subnet and NSG — the smallest
useful starting point for a workload on Azure.

```
              Internet
                 │
         ┌───────▼────────┐
         │  Public IP     │  Standard, static
         │  (or NAT GW)   │
         └───────┬────────┘
                 │
   snet 10.0.1.0/24  ← NSG: app port + deny-all
         ┌───────▼────────┐
         │  Linux VM      │  SSH-key only, managed identity
         │  Standard_B2s  │  encrypted managed disk
         └────────────────┘
```

## What it creates

- **Resource group** holding everything, so cleanup is one delete.
- **Virtual network** and one subnet (`networking.tf`).
- **NSG** allowing `var.app_port` from `var.ingress_cidr`, with an explicit
  deny-all-inbound rule at priority 4096. Associated with **both** the subnet and
  the NIC.
- **Public IP** *or* **NAT gateway**, depending on `assign_public_ip`.
- **Linux VM** (`virtual_machine.tf`) with a system-assigned managed identity and
  boot diagnostics.
- **Optional data disk**, when `data_disk_size_gb > 0`.

## Security posture

- **No SSH by default.** `allow_ssh` is `false`, so port 22 is closed. Use Azure
  Bastion, or:
  ```bash
  az serial-console connect --name vm-<prefix> --resource-group rg-<prefix>
  ```
  If you do set `allow_ssh = true`, `ssh_source_cidr` defaults to `10.0.0.0/8`
  rather than the internet — **never** widen it to `0.0.0.0/0`.
- **Password authentication is disabled.** `ssh_public_key` is required.
- **Explicit deny-all inbound** at priority 4096, so a future rule added at a
  higher priority has to be deliberate.
- **Managed identity** instead of stored credentials.
- Managed disks are encrypted at rest with platform keys by default and cannot be
  turned off. `encryption_at_host_enabled` extends that to the temp disk and
  caches.

## Getting started

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars   # then edit
terraform init
terraform validate
terraform plan
terraform apply
```

Three inputs have no default: `subscription_id`, `tenant_id` and
`ssh_public_key`.

```bash
az account show --query "{sub:id, tenant:tenantId}"
cat ~/.ssh/id_rsa.pub
```

## Notes

- **Outbound access needs one or the other.** Azure is retiring default outbound
  access, so a VM with neither a public IP nor a NAT gateway will have **no
  internet egress** — package installs and agent registration would fail. This
  template always gives you one: a public IP when `assign_public_ip = true`, a NAT
  gateway when it's `false`.
- **`admin_username` cannot be a reserved name.** Azure rejects `admin`, `root`,
  `administrator` and others; the variable validates this rather than letting the
  apply fail.
- **`ignore_changes = [source_image_reference]`** — Azure rewrites `version =
  "latest"` to the resolved build number, which would otherwise appear as drift on
  every plan.
- **`os_disk_size_gb` must be at least as large as the image**, or the apply
  fails. 30 GB is safe for Ubuntu 22.04.
- **`encryption_at_host_enabled` is not supported on every VM size** and must be
  enabled on the subscription first:
  ```bash
  az feature register --namespace Microsoft.Compute --name EncryptionAtHost
  ```
- `custom_data` installs nginx as a placeholder so the port answers on a fresh
  apply. Replace it with your real bootstrap.

## Before production

| Setting | Change to | Why |
|---|---|---|
| `ingress_cidr` | your own range | The default is the entire internet |
| `assign_public_ip` | `false` | Put a load balancer in front instead |
| `os_disk_type` | `Premium_LRS` | Consistent disk latency |
| `encryption_at_host_enabled` | `true` | Covers temp disk and caches too |
| Remote state | Uncomment `backend "azurerm"` in `providers.tf` | Team-safe state with locking |
| Backup | Add a Recovery Services vault and a backup policy | A single VM has no redundancy |

A single VM is a single point of failure. For availability, the natural next step
is a scale set behind a load balancer — see the **3-Tier App on Azure** template.

## Cost

At defaults in `eastus`: `Standard_B2s` is ~$30/mo, a 30 GB StandardSSD disk
~$2.40/mo, and a Standard static public IP ~$3.60/mo. Setting
`assign_public_ip = false` swaps that public IP for a NAT gateway, which is
*more* expensive (~$32/mo plus data) — so for a single dev VM, a public IP with a
narrow `ingress_cidr` is the cheaper choice.
