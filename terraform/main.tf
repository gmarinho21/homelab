resource "proxmox_vm_qemu" "kube-master-1" {
  name        = "kube-master-1"
  target_node = "pve2"
  clone       = "template"
  full_clone  = true
  os_type     = "ubuntu"  
  cores       = 4      
  memory      = 4096       
  bios = "ovmf"
  agent = 1
  
  disk {
    size     = "64G"
    storage  = "local-lvm"       # Storage pool where the disk is located
    slot     = "scsi0"           # Interface slot to attach the disk
  }
    scsihw   = "virtio-scsi-pci"

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
    firewall = true
  }
}

resource "proxmox_vm_qemu" "kube-node-1" {
  name        = "kube-node-1"
  target_node = "pve2"
  clone       = "template"
  full_clone  = true
  os_type     = "ubuntu"  
  cores       = 3      
  memory      = 2048
  bios = "ovmf"
  agent = 1
  scsihw   = "virtio-scsi-pci"

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
  name        = "kube-node-2"
  target_node = "pve2"
  clone       = "template"
  full_clone  = true
  os_type     = "ubuntu"  
  cores       = 3      
  memory      = 2048       
  bios = "ovmf"
  agent = 1
  scsihw   = "virtio-scsi-pci"

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
