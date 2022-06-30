#!/usr/bin/env bash

qm create 9000 --memory 2048 --net0 virtio,bridge=vmbr1 --name ubuntu-base-template

# latest supported version: Ubuntu 20
qm importdisk 9000 /root/img/focal-server-cloudimg-amd64.img local-zfs

# Ubuntu 22 is not yet supported
#qm importdisk 9000 /root/img/jammy-server-cloudimg-amd64.img local-zfs

qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-zfs:vm-9000-disk-0

qm set 9000 --ide2 local-zfs:cloudinit
qm set 9000 --boot c --bootdisk scsi0

qm set 9000 --serial0 socket --vga serial0

qm cloudinit dump 9000 user
qm template 9000
