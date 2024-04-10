# Terraform for PVE

## Preparation: Template from Cloud-Init-Image
(see https://pve.proxmox.com/wiki/Cloud-Init_Support)
* Adapt the script `pve-prepare.sh` for your preferred VM images, VM IDs and storage names. The default script will download the latest Ubuntu distro cloud init images and prefix the major release version with 90 for the VM ID such that e.g. Ubuntu 22 has ID 9022. Storage degault is `local-zfs` from my local PVE.
* Copy and run `pve-prepare.sh` on your PVE hypervisor !

## Use Cloud-Init Provisioning
Disks are resized in cloud init phase. For more details also see:
* https://vectops.com/2020/05/provision-proxmox-vms-with-terraform-quick-and-easy/
* https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/vm_qemu#provision-through-cloud-init
* https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/guides/cloud_init

## Configure and Deploy
* Make sure to create yor PVE user with the correct roles and an API token as documented: https://github.com/Telmate/terraform-provider-proxmox/blob/master/docs/index.md
* In case of release-updates double-check the permissions for the `TerraformProv` role in PVE with the documentation.
