# rke2

## PVE VM Setup with Terraform
Switch into the Terraform directory and follow the README there.

## Install rke2 using ansible
* One-command deployment (or uninstall) using th eprovided scripts:
  * `setup_rke2.sh` - Default RKE2 installation based on Ubuntu 22 (based on this blog post: https://www.pivert.org/rke2-cluster-on-ubuntu-22-04-in-minutes-ansible-galaxy-and-manual-options/)
  * `setup_rke2_cilium.sh` - RKE2 installation with Cilium 

## Get Started
The Ansible playbook will create a local `kubeconf.yaml` file, just copy it over to `~/.kube/config` and try to list your nodes:
```shell
cp -v kubeconf.taml ~/.kube/config
kubectl get nodes
```

### Deploy further tools
This folder contains scripts to deploy longhorn, certman and ranger. The Ranger-Script is configured to use a pre-generated certificate in a secret so you need to deploy and configure Certman first !
The RKE2 installatikon comes without a defult storage class so feel free to simply deploy longhorn so you don't run into issues with persistent volume claims!

### Accessing rke2 outside of your local network (tunneling,NAT)
Access to you internal k8s network is done using NAT / reverse proxy and adding external ip/hostname to tls-san (see configuration).
  * In you kube-config, you can now change the server-field to `server: https://<external hostname/ip>:6443` and that's it!
  
