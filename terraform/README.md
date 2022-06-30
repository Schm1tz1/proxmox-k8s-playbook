# Terraform for PVE

## Prepare: Template from Cloud-Init-Image
(see https://pve.proxmox.com/wiki/Cloud-Init_Support)
* use the scripts in preparation directory before starting terraform!
* Have a look at the numbering scheme: The startup order will be lowest to highest (and shutdown order vice versa). In the current scheme we are limited to 9 nodes of each type which should be more than enough. If you need more, change the VM-IDs accordingly! 
* Most important point: cloud init in PVE work with a virtual cdrom drive. **DO NOT** forget to create one!

Example for ubuntu jammy:
```
# download the image
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img

# create a new VM
qm create 9000 --memory 2048 --net0 virtio,bridge=vmbr1 --name CP-Template
qm importdisk 9000 /root/img/jammy-server-cloudimg-amd64.img local-zfs
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-zfs:vm-9000-disk-0

qm set 9000 --ide2 local-zfs:cloudinit
qm set 9000 --boot c --bootdisk scsi0

qm set 9000 --serial0 socket --vga serial0

qm cloudinit dump 9000 user
qm template 9000

```
For Debian Buster you can use the same script, simply change the image: https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2

## Configure
### Add credentials
Example credential can be added to a file *credentials.auto.tfvars* - example:
```
proxmox_api_url          = "https://10.10.10.1:8006/api2/json"
proxmox_api_token_id     = "terraform-provider@pve!terraform-20201231"
proxmox_api_token_secret = "ffffffff-eeee-dddd-cccc-bbbbbbbbbbbb"
```
### Use Cloud-Init Provisioning
Disks are resized in cloud init phase. For more details also see:
* https://vectops.com/2020/05/provision-proxmox-vms-with-terraform-quick-and-easy/
* https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/vm_qemu#provision-through-cloud-init
* https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/guides/cloud_init
