
locals {
  server_numas = length(var.cpu_affinity)

  server_cpus = [for i in var.cpu_affinity :
    flatten([for r in split(",", i) : (strcontains(r, "-") ? range(split("-", r)[0], split("-", r)[1] + 1, 1) : [r])])
  ]

  cpus = [for k, v in local.server_cpus :
    flatten([flatten([for r in range(length(v) / 2) : [v[r], v[r + length(v) / 2]]])])
  ]

  shift = var.shift >= 0 ? var.shift * length(try(local.cpus[0], [])) : max(local.cpus[local.server_numas + var.shift]...) - (var.vms * var.cpus - 1)

  vm_arch = { for k in flatten([
    for inx in range(var.vms) : {
      inx : var.shift >= 0 ? inx : var.vms - inx - 1
      cpus : slice(flatten(local.cpus), inx * var.cpus + local.shift, (inx + 1) * var.cpus + local.shift)
      shift : local.shift
      numa : { for numa in range(length(var.cpu_affinity)) : numa => setintersection(local.cpus[numa], slice(flatten(local.cpus), inx * var.cpus + local.shift, (inx + 1) * var.cpus + local.shift)) }
    }
  ]) : k.inx => k }
}
