#!/usr/bin/env bash

STORAGE=local-zfs
VMID_PREFIX=90
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

    echo " * Removing old VM ${VMID}..."
    qm destroy ${VMID} --purge

    echo "  * Creating template VM ${VMID} from image ${IMAGE}..."

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
create_template ${VMID_PREFIX}20 ubuntu20-base-template ${TMPDIR}/focal-server-cloudimg-amd64.img
create_template ${VMID_PREFIX}22 ubuntu22-base-template ${TMPDIR}/jammy-server-cloudimg-amd64.img
create_template ${VMID_PREFIX}24 ubuntu24-base-template ${TMPDIR}/noble-server-cloudimg-amd64.img

echo "Cleaning up..."
rm -vir ${TMPDIR}
