
variable "cpu_affinity" {
  description = "CPU numa affinity list"
  type        = list(string)
  default     = ["0-15,64-79", "16-31,80-95", "32-47,96-111", "48-63,112-127"]
}

variable "vms" {
  type    = number
  default = 1
}

variable "cpus" {
  type    = number
  default = 4
}

variable "shift" {
  type    = number
  default = 0
}
