terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.73.0"
    }
  }
}

provider "proxmox" {
  endpoint = "https://pve.gabrielm.com.br"
  api_token = var.virtual_environment_api_token
  insecure  = true
  ssh {
    agent = true
    username = "root"
    private_key = file("~/.ssh/id_rsa_terraform")
  }
}
