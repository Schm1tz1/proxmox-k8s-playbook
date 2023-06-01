# k3s

## Install k3s using ansible
* clone **k3s-io/k3s-ansible**: `git clone https://github.com/k3s-io/k3s-ansible.git`
* go into [k3s-ansible](./k3s-ansible/)
* copy the example inventory `cp -R inventory/sample inventory/pve-cluster`
* adapt `inventory/pve-cluster/hosts.ini` to your needs, example:
```
[master]
10.0.0.20

[node]
10.0.0.21
10.0.0.22
10.0.0.23

[k3s_cluster:children]
master
node
```
* Default configuration is for debian. In case you use a different distro, please adapt the ansible user in (inventory/pve-cluster/group_vars/all.yml) (e.g. ubuntu for Ubuntu), example:
```
---
k3s_version: v1.22.3+k3s1
ansible_user: ubuntu
systemd_dir: /etc/systemd/system
master_ip: "{{ hostvars[groups['master'][0]]['ansible_host'] | default(groups['master'][0]) }}"
extra_server_args: ""
extra_agent_args: ""
```
* Deploy k3s with `ansible-playbook site.yml -i inventory/pve-cluster/hosts.ini`
  With my setup (Ubuntu 20 nodes on PVE) I ran into issues in the K3s service check which does a systemd reload of the services. Accordibg to the logs it is trying to start the load balancer twice an thus fails. Nevertheless the cluster is fully configured, up and running. Log of my error
```
TASK [k3s/node : Enable and check K3s service] *************************************************************************
fatal: [10.0.0.20]: FAILED! => {"changed": false, "msg": "Unable to restart service k3s-node: Job for k3s-node.service failed because the control process exited with error code.\nSee \"systemctl status k3s-node.service\" and \"journalctl -xe\" for details.\n"}
```
* You can reset your nodes with `ansible-playbook reset.yml -i inventory/pve-cluster/hosts.ini`

(For more details also see https://www.suse.com/c/rancher_blog/deploying-k3s-with-ansible/)

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

### Accessing k3s outside of your local network (tunneling,NAT)

#### Option 1 (hacky): SSH-tunnel using a jumphost
* SSL certificate on k3s master is perdefault generated for its IP and localhost. To simplify the connection over a jump-host, use ssh for port-forwarding and adapt the `.kube/config` to localhost
  * Example `.kube/config`:
    ```
    apiVersion: v1
    clusters:
    - cluster:
        certificate-authority-data: (...)
        server: https://localhost:6443
    name: default
    contexts:
    - context:
        cluster: default
        user: default
    name: default
    current-context: default
    kind: Config
    preferences: {}
    users:
    - name: default
    user:
        client-certificate-data: (...)
        client-key-data: (...)
    ```
  * SSH-tunnel: `ssh -N -L 6443:<k3s-master>:6443 <jumphost>`
  * Local test:
    ```
    % kubectl get po -A
    NAMESPACE     NAME                                     READY   STATUS      RESTARTS   AGE
    kube-system   metrics-server-9cf544f65-n7q7f           1/1     Running     0          9h
    kube-system   coredns-85cb69466-6jxh2                  1/1     Running     0          9h
    kube-system   local-path-provisioner-64ffb68fd-sk2fq   1/1     Running     0          9h
    kube-system   helm-install-traefik-crd--1-xgr9g        0/1     Completed   0          9h
    kube-system   helm-install-traefik--1-pvkwz            0/1     Completed   1          9h
    kube-system   svclb-traefik-vpqzb                      2/2     Running     0          9h
    kube-system   svclb-traefik-wmbrq                      2/2     Running     0          9h
    kube-system   svclb-traefik-zzkp7                      2/2     Running     0          9h
    kube-system   traefik-74dd4975f9-7j8qj                 1/1     Running     0          9h
    ```
#### Option 2 (cleaner): Use NAT / reverse proxy and add external ip/hostname to tls-san
  * Forward a port or run a reverse proxy to your kube master port. This might be as simple as forwarding port 6443 to the master node in your firewall or running haproxy/nginx reverse proxy.
  * You need to run the k3s server with the option `--tls-san <external hostname/ip>` to have the external address added to your DNS/SAN in the certificate. As certificates are created on a regular basis, it is safe to do this upon installation with ansible and/or re-deploy at least the master node. Simply adding the option to the systemd script and restarting will not work!
    * in the group vars (e.g. `k3s/pve_cluster/group_vars/all.yml`), set `extra_server_args: "--tls-san <external hostname/ip>"`
    * re-run the playbook
    * boot up your node, verify that in `/etc/systemd/system/k3s.service` on your master you can see `ExecStart=/usr/local/bin/k3s server --data-dir /var/lib/rancher/k3s --tls-san <external hostname/ip>`
    * check your certificate SAN, e.g. `echo | openssl s_client -connect <master node ip>:6443 -prexit 2>/dev/null | openssl x509 -text`. You should see something like this including your specified `<external hostname/ip>`:
    ```
    ...
    X509v3 Subject Alternative Name:
    DNS:k8s-master-0, DNS:kubernetes, DNS:kubernetes.default, DNS:kubernetes.default.svc, DNS:kubernetes.default.svc.cluster.local, DNS:localhost, IP Address:10.0.0.20, IP Address:10.43.0.1, IP Address:127.0.0.1, IP Address:192.168.178.3
    ...
    ```
  * In you kube-config, you can now change the server-field to `server: https://<external hostname/ip>:6443` and that's it!
  
