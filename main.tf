
locals {
  server_cpus = [for i in var.cpu_affinity :
    flatten([for r in split(",", i) : (strcontains(r, "-") ? range(split("-", r)[0], split("-", r)[1] + 1, 1) : [r])])
  ]

  cpus = [for k, v in local.server_cpus :
    var.shift >= 0 ? flatten([flatten([for r in range(length(v) / 2) : [v[r], v[r + length(v) / 2]]])]) : reverse(flatten([flatten([for r in range(length(v) / 2) : [v[r], v[r + length(v) / 2]]])]))
  ]

  shift = var.shift >= 0 ? var.shift * length(try(local.cpus[0], [])) : abs(length(var.cpu_affinity) + var.shift) * length(try(local.cpus[0], []))

  vm_arch = { for k in flatten([
    for inx in range(var.vms) : {
      inx : var.shift >= 0 ? inx : var.vms - inx - 1
      cpus : var.shift >= 0 ? slice(flatten(local.cpus), inx * var.cpus + local.shift, (inx + 1) * var.cpus + local.shift) : slice(flatten(local.cpus), (inx - 1) * var.cpus + local.shift, inx * var.cpus + local.shift)
      shift : local.shift
      numa : var.shift >= 0 ? { for numa in range(length(var.cpu_affinity)) : numa => setintersection(local.cpus[numa], slice(flatten(local.cpus), inx * var.cpus + local.shift, (inx + 1) * var.cpus + local.shift)) } : { for numa in range(length(var.cpu_affinity)) : numa => setintersection(local.cpus[numa], slice(flatten(local.cpus), (inx - 1) * var.cpus + local.shift, inx * var.cpus + local.shift)) }
    }
  ]) : k.inx => k }
}
