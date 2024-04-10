# rke2

## PVE VM Setup with Terraform
Switch into the Terraform directory and follow the README there.

## Install rke2 using ansible
* One-command deployment (or uninstall) using th eprovided scripts:
  * `setup_rke2.sh` - Default RKE2 installation based on Ubuntu 22 (based on this blog post: https://www.pivert.org/rke2-cluster-on-ubuntu-22-04-in-minutes-ansible-galaxy-and-manual-options/)
  * `setup_rke2_cilium.sh` - RKE2 installation with Cilium (WIP)

## Get Started
* copy kube-config: `scp -v ubuntu@10.0.0.20:~/.kube/config ~/.kube/config`

### Use different Ingress Controllers
* Disable *traefik* by adding `extra_server_args: "--no-deploy traefik"` in pve_cluster/group_vars/all.yml
* Install e.g. *NGINX* via helm: 
```
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace
```
(also see https://kubernetes.github.io/ingress-nginx/)

### Accessing rke2 outside of your local network (tunneling,NAT)
Access to you internal k8s network is done using NAT / reverse proxy and adding external ip/hostname to tls-san.
Steps:
  * Forward a port or run a reverse proxy to your kube master port. This might be as simple as forwarding port 6443 to the master node in your firewall or running haproxy/nginx reverse proxy.
  * You need to run the k3s server with the option `--tls-san <external hostname/ip>` to have the external address added to your DNS/SAN in the certificate. As certificates are created on a regular basis, it is safe to do this upon installation with ansible and/or re-deploy at least the master node. Simply adding the option to the systemd script and restarting will not work!
    * Make sure you have set the `extra_server_args: "--tls-san 192.168.178.3` pointing to your external IP/hostname you are using for ingress (192.168.178.3 in my case) in you inventory.
    * boot up your node, verify that in `/etc/systemd/system/k3s.service` on your master you can see `ExecStart=/usr/local/bin/k3s server --data-dir /var/lib/rancher/k3s --tls-san <external hostname/ip>`
    * check your certificate SAN, e.g. `echo | openssl s_client -connect <master node ip>:6443 -prexit 2>/dev/null | openssl x509 -text`. You should see something like this including your specified `<external hostname/ip>`:
    ```
    ...
    X509v3 Subject Alternative Name:
    DNS:k8s-master-0, DNS:kubernetes, DNS:kubernetes.default, DNS:kubernetes.default.svc, DNS:kubernetes.default.svc.cluster.local, DNS:localhost, IP Address:10.0.0.20, IP Address:10.43.0.1, IP Address:127.0.0.1, IP Address:192.168.178.3
    ...
    ```
  * In you kube-config, you can now change the server-field to `server: https://<external hostname/ip>:6443` and that's it!
  