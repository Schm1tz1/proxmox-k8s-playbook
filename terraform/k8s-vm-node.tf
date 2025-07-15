resource "proxmox_vm_qemu" "k8s-node" {
  count        = var.node-count
  name         = "k8s-node-${count.index}"
  vmid         = "${var.node_prefix}${count.index}"
  desc         = "k8s node ${count.index}"
  clone        = var.proxmox_vm_template
  target_node  = "atlas"

  agent        = 0
  bios         = "seabios"
  scsihw       = "virtio-scsi-pci"
  
  os_type      = "cloud-init"
  ciupgrade    = true
  ipconfig0    = "ip=10.0.0.2${var.master-count+count.index}/24,gw=${var.network_gateway}"
  nameserver   = "10.0.0.1"
  ssh_user     = var.ssh_user
  sshkeys      = var.ssh_key

  memory       = 6144

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
          size               = "32G"
          storage            = "local-zfs"
        }
      }
    }
  }

}
