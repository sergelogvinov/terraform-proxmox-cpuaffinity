
output "arch" {
  value = { for k, v in local.vm_arch : k => {
    cpus : var.shift >= 0 ? v.cpus : reverse(v.cpus)
    numa : { for numa in range(length(var.cpu_affinity)) : numa => v.numa[numa] if length(v.numa[numa]) > 0 }
    }
  }
}
