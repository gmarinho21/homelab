resource "proxmox_vm_qemu" "kube-master-1" {
  name        = "terraform-created"
  target_node = "pve"
  clone       = "empty-template"
  full_clone  = true
  os_type     = "ubuntu"  
  cores       = 1      
  memory      = 2048       

  disk {
    size     = "64G"
    storage  = "local-lvm"       # Storage pool where the disk is located
    slot     = "scsi0"           # Interface slot to attach the disk
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
    firewall = true
  }
}

resource "proxmox_vm_qemu" "kube-node-1" {
  name        = "terraform-created"
  target_node = "pve"
  clone       = "empty-template"
  full_clone  = true
  os_type     = "ubuntu"  
  cores       = 1      
  memory      = 2048       

  disk {
    size     = "64G"
    storage  = "local-lvm"       # Storage pool where the disk is located
    slot     = "scsi0"           # Interface slot to attach the disk
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
    firewall = true
  }
}

resource "proxmox_vm_qemu" "kube-node-2" {
  name        = "terraform-created"
  target_node = "pve"
  clone       = "empty-template"
  full_clone  = true
  os_type     = "ubuntu"  
  cores       = 1      
  memory      = 2048       

  disk {
    size     = "64G"
    storage  = "local-lvm"       # Storage pool where the disk is located
    slot     = "scsi0"           # Interface slot to attach the disk
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
    firewall = true
  }
}
