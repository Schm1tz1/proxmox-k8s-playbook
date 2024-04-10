#!/usr/bin/env bash

TMPDIR=/tmp/k8s-tmp

pull_images() {
    wget -nc https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img -P ${TMPDIR}
    wget -nc https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img -P ${TMPDIR}
    wget -nc https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img -P ${TMPDIR}
}

create_template() {
    VMID=$1
    NAME=$2
    IMAGE=$3
    STORAGE=$4

    echo "  * Creating template VM ${VMIU} from image ${IMAGE}..."

    qm create ${VMID} --memory 2048 --net0 virtio,bridge=vmbr1 --name ${NAME}
    qm importdisk ${VMID} ${IMAGE} ${STORAGE}

    qm set ${VMID} --scsihw virtio-scsi-pci --scsi0 ${STORAGE}:vm-${VMID}-disk-0
    qm set ${VMID} --ide2 ${STORAGE}:cloudinit
    qm set ${VMID} --boot c --bootdisk scsi0
    qm set ${VMID} --serial0 socket --vga serial0

    qm cloudinit dump ${VMID} user
    qm template ${VMID}
}

echo "Downloading VM CloudInit images..."
pull_images

echo "Creating template VMs..."
create_template 9020 ubuntu20-base-template ${TMPDIR}/focal-server-cloudimg-amd64.img local-zfs
create_template 9022 ubuntu22-base-template ${TMPDIR}/jammy-server-cloudimg-amd64.img local-zfs
create_template 9024 ubuntu24-base-template ${TMPDIR}/noble-server-cloudimg-amd64.img local-zfs

echo "Cleaning up..."
rm -vir ${TMPDIR}
