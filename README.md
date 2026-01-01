# Terraform module for Proxmox VE

This Terraform module calculates the CPU list for virtual machines based on the configured number of CPU cores and CPU sockets.

It is intended for use with the CPU affinity feature in Proxmox VE, where specific physical CPU cores are explicitly pinned to a VM.
By generating a deterministic CPU list, the module helps ensure predictable performance, better NUMA locality, and reduced CPU contention on the host.

## Usage

```hcl

module "cpus" {
  source       = "sergelogvinov/terraform-proxmox-cpuaffinity"

  cpu_affinity = ["0-15,64-79", "16-31,80-95", "32-47,96-111", "48-63,112-127"]

  # Number of VMs
  vms   = 2

  # Number of CPU cores per VM
  cpus  = 8

  # Optional shift for CPU Numa nodes (default is 0)
  shift = 0
}

```
