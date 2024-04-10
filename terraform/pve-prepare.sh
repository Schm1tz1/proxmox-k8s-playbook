#!/usr/bin/env bash

pull_images() {
    wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img -P ${TMPDIR}
    wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img -P ${TMPDIR}
    wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img -P ${TMPDIR}
}

create_template() {
    VMID=$1
    IMAGE=$2

    echo "  * Creating template VM ${VMIU} from image ${IMAGE}..."

    qm create ${VMID} --memory 2048 --net0 virtio,bridge=vmbr1 --name ubuntu24-base-template
    qm importdisk ${VMID} ${IMAGE}

    qm set ${VMID} --scsihw virtio-scsi-pci --scsi0 local-zfs:vm-${VMID}-disk-0
    qm set ${VMID} --ide2 local-zfs:cloudinit
    qm set ${VMID} --boot c --bootdisk scsi0
    qm set ${VMID} --serial0 socket --vga serial0

    qm cloudinit dump ${VMID} user
    qm template ${VMID}
}

echo "Downloading VM CloudInit images..."
pull_images

echo "Creating template VMs..."
create_template 9020 ${TMPDIR}/focal-server-cloudimg-amd64.img
create_template 9022 ${TMPDIR}/jammy-server-cloudimg-amd64.img
create_template 9024 ${TMPDIR}/noble-server-cloudimg-amd64.img
