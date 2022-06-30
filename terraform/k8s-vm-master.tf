resource "proxmox_vm_qemu" "master" {
  count        = var.master-count
  name         = "k8s-master-${count.index}"
  vmid         = "200${count.index}"
  desc         = "k8s master ${count.index}"
  clone        = var.proxmox_vm_template
  target_node  = "atlas"

  os_type      = "cloud-init"
  ipconfig0    = "ip=10.0.0.2${count.index}/24,gw=${var.network_gateway}"
  ssh_user     = "ubuntu"
  sshkeys      = var.ssh_key

  cores        = 2
  sockets      = 1
  memory       = 8192

  disk {
    size            = "16G"
    type            = "scsi"
    storage         = "local-zfs"
  }

}
