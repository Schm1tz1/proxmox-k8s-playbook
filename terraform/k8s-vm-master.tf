resource "proxmox_vm_qemu" "master" {
  count        = var.master-count
  name         = "k8s-master-${count.index}"
  vmid         = "200${count.index}"
  desc         = "k8s master ${count.index}"
  clone        = var.proxmox_vm_template
  target_node  = "atlas"

  agent        = 0
  bios         = "seabios"
  scsihw       = "virtio-scsi-pci"

  os_type      = "cloud-init"
  ipconfig0    = "ip=10.0.0.2${count.index}/24,gw=${var.network_gateway}"
  nameserver   = "10.0.0.1"
  ssh_user     = "ubuntu"
  sshkeys      = var.ssh_key

  cores        = 1
  sockets      = 1
  memory       = 3072

  disk {
    size            = "8G"
    type            = "scsi"
    storage         = "local-zfs"
  }

}
