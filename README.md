# Terraform module for Proxmox VE

This Terraform module calculates the CPU list for virtual machines based on the configured number of CPU cores and CPU sockets.

It is intended for use with the CPU affinity feature in Proxmox VE, where specific physical CPU cores are explicitly pinned to a VM.
By generating a deterministic CPU list, the module helps ensure predictable performance, better NUMA locality, and reduced CPU contention on the host.

## Usage

In example:

* var.vms == 16
* var.vms == 2

```hcl

module "cpus" {
  source       = "github.com/sergelogvinov/terraform-proxmox-cpuaffinity"

  cpu_affinity = ["0-15,64-79", "16-31,80-95", "32-47,96-111", "48-63,112-127"]

  # Number of VMs
  vms   = var.vms

  # Number of CPU cores per VM
  cpus  = var.cpus

  # Optional shift for CPU Numa nodes (default is 0)
  shift = 0
}

resource "proxmox_virtual_environment_vm" "vms" {
  count = var.vms

  name       = "vm-${count.index}"
  vmid       = 100 + count.index
  target_node = "proxmox-node"

  cpu {
    cores        = var.cpus
    sockets      = 1
    cpu_affinity = join(",", module.cpus.arch[count.index].cpus)
  }

}

```

## Inputs

- `cpu_affinity` - List of CPU ranges for each NUMA node on the Proxmox host. In the format `["0-15,64-79", "16-31,80-95", ...]`.
  `"0-15,64-79"` means that the first NUMA node has CPUs 0 to 15 and 64 to 79 are the hyperthreaded cores.
- `vms` - Number of virtual machines to configure.
- `cpus` - Number of CPU cores to assign to each VM. Amount of CPUs should be less than or equal to total available CPUs in NUMA node.
- `shift` - Optional shift for CPU Numa nodes (default is 0). If negative, the CPU list will be allocated in reverse order from last NUMA node to first.

## Outputs

- `arch` - A map of VM indices to their assigned CPU lists and NUMA node mappings.
  Example:
  ```hcl
  {
    0 = {
      cpus = [
        "0",
        "64",
        "1",
        "65",
        "2",
        "66",
        "3",
        "67",
        "4",
        "68",
        "5",
        "69",
        "6",
        "70",
        "7",
        "71",
      ]
    }
    1 = {
      cpus = [
        "8",
        "72",
        "9",
        "73",
        "10",
        "74",
        "11",
        "75",
        "12",
        "76",
        "13",
        "77",
        "14",
        "78",
        "15",
        "79",
      ]
    }
  }
  ```