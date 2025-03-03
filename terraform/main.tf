data "local_file" "ssh_public_key" {
  filename = "/home/jaka/.ssh/id_rsa_proxmox.pub"
}

resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  for_each = var.vm_metadata

  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve2"

  source_raw {
    data = <<-EOF
    #cloud-config
    users:
      - default
      - name: jaka
        groups:
          - sudo
        shell: /bin/bash
        ssh_authorized_keys:
          - ${trimspace(data.local_file.ssh_public_key.content)}
        sudo: ALL=(ALL) NOPASSWD:ALL
    runcmd:
        - apt update
        - apt install -y qemu-guest-agent net-tools
        - timedatectl set-timezone America/Cuiaba
        - systemctl enable qemu-guest-agent
        - systemctl start qemu-guest-agent
        - echo "done" > /tmp/cloud-config.done
    EOF

    file_name = "user-data-cloud-config-${each.key}.yaml"
  }
}

resource "proxmox_virtual_environment_file" "meta_data_cloud_config" {
  for_each = var.vm_metadata

  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve2"

  source_raw {
    data = <<-EOF
    #cloud-config
    local-hostname: ${each.value.hostname}
    EOF

    file_name = "meta-data-cloud-config-${each.key}.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "k3s-cluster-vms" {
  for_each = var.vm_metadata

  name      = each.value.hostname
  node_name = "pve2"

  vm_id = each.value.vm_id

  agent {
    enabled = true
  }

  initialization {
    ip_config {
      ipv4 {
        address = each.value.ip
        gateway = each.value.gateway
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config[each.key].id
    meta_data_file_id = proxmox_virtual_environment_file.meta_data_cloud_config[each.key].id
  }

  cpu {
    cores = 2
    type  = "x86-64-v2-AES" # recommended for modern CPUs
  }

  memory {
    dedicated = 2048
    floating  = 2048 # set equal to dedicated to enable ballooning
  }
  bios = "seabios"

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "scsi0"
    size         = 20
  }

  network_device {
    bridge = "vmbr0"
  }
}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve2"

  url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}


