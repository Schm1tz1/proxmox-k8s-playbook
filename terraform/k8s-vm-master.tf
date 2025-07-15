resource "proxmox_vm_qemu" "k8s-master" {
  count        = var.master-count
  name         = "k8s-master-${count.index}"
  vmid         = "${var.master_prefix}${count.index}"
  desc         = "k8s master ${count.index}"
  clone        = var.proxmox_vm_template
  target_node  = "atlas"

  agent        = 0
  bios         = "seabios"
  scsihw       = "virtio-scsi-pci"

  os_type      = "cloud-init"
  ciupgrade    = true
  ipconfig0    = "ip=10.0.0.2${count.index}/24,gw=${var.network_gateway}"
  nameserver   = "10.0.0.1"
  ssh_user     = var.ssh_user
  sshkeys      = var.ssh_key

  memory       = 3072

  cpu {
    cores        = 2
    sockets      = 1
  }

  network {
    id        = 0
    bridge    = "vmbr1"
    model     = "virtio"
  }

  disks {
    ide {
      ide2 {
        cloudinit {
          storage = "local-zfs"
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          backup             = true
          cache              = "none"
          discard            = true
          emulatessd         = true
          iothread           = true
          size               = "16G"
          storage            = "local-zfs"
        }
      }
    }
  }

}
