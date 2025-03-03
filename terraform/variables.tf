variable "vm_name" {
  type        = string
  description = "Name of the VM"
}

variable "target_node" {
  type        = string
  description = "Proxmox node to deploy on"
}

variable "template_name" {
  type        = string
  description = "Template to clone from"
}

variable "cores" {
  type    = number
  default = 2
}

variable "memory" {
  type    = number
  default = 4096
}

variable "virtual_environment_api_token" {
  description = "Proxmox API Token Secret"
  type        = string
}

variable "vm_metadata" {
  type = map(object({
    hostname = string
    ip       = string
    gateway  = string
  }))
  default = {
    "kube-master-1" = {
      hostname = "kube-master-1"
      ip       = "192.168.0.240/24"
      gateway  = "192.168.0.1"
    }
    "kube-node-1" = {
      hostname = "kube-node-1"
      ip       = "192.168.0.241/24"
      gateway  = "192.168.0.1"
    }
  }
}
