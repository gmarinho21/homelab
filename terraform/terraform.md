# Terraform Setup with Proxmox

The provider require SSH access for commands that are not available through the Proxmox API. Be sure to provide SSH keys in the provider block.

Terraform will create the VMs defined vm_metadata variable in variables.tf. Each VM will have QEMU Agent installed.

**Note:** It's also necessary to enable snippets in the local storage.  
You can enable snippets by going to **Datacenter > Storage** in the Proxmox interface before using this resource for the first time.


