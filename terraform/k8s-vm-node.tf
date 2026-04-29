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
  ipconfig0    = "ip=${var.node_subnet}.${var.node_ip_prefix}${count.index}/24,gw=${var.network_gateway}"
  nameserver   = var.dns_server
  ssh_user     = var.ssh_user
  cipassword   = var.ssh_password
  sshkeys      = var.ssh_key

  memory       = 6144

  cpu {
    cores        = 2
    sockets      = 1
  }

  network {
    id        = 0
    bridge    = var.network_bridge
    model     = "virtio"
    tag       = var.vlan_tag
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

  serial {
    id   = 0
    type = "socket"
  }

}
