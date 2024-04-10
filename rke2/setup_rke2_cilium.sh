#!/usr/bin/env bash

ansible-galaxy install lablabs.rke2

cat <<EOF > hosts.ini
[masters]
master-01 ansible_host=10.0.0.20 rke2_type=server

[workers]
worker-01 ansible_host=10.0.0.21 rke2_type=agent
worker-02 ansible_host=10.0.0.22 rke2_type=agent
worker-03 ansible_host=10.0.0.23 rke2_type=agent
worker-04 ansible_host=10.0.0.24 rke2_type=agent
worker-05 ansible_host=10.0.0.25 rke2_type=agent
worker-06 ansible_host=10.0.0.26 rke2_type=agent

[k8s_cluster:children]
masters
workers
EOF

cat <<EOF > deploy_rke2.yaml
- name: Deploy RKE2
  hosts: k8s_cluster
  become: yes
  vars:
    ansible_user: ubuntu
    rke2_server_options:
      - "cni: cilium"
    rke2_ha_mode: false
    rke2_api_ip: 10.0.0.20
    rke2_download_kubeconf: true
    rke2_download_kubeconf_file_name: kubeconf.yaml
    rke2_download_kubeconf_path: ./
    rke2_additional_sans: 
      - gate.internal.schmitzi.net
      - 192.168.178.3
  roles:
    - role: lablabs.rke2
EOF

# ansible-playbook -i hosts.ini deploy_rke2.yaml
