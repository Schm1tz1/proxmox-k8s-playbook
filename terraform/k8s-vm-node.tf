resource "proxmox_vm_qemu" "node" {
  count        = var.node-count
  name         = "k8s-node-${count.index}"
  vmid         = "201${count.index}"
  desc         = "k8s node ${count.index}"
  clone        = var.proxmox_vm_template
  target_node  = "atlas"

  os_type      = "cloud-init"
  ipconfig0    = "ip=10.0.0.2${var.master-count+count.index}/24,gw=${var.network_gateway}"
  ssh_user     = "ubuntu"
  sshkeys      = var.ssh_key

  cores        = 2
  sockets      = 1
  # memory       = 8192
  memory       = 6144

  disk {
    size            = "20G"
    type            = "scsi"
    storage         = "local-zfs"
  }

}
