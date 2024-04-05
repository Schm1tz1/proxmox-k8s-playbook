#!/usr/bin/env bash

git clone https://github.com/k3s-io/k3s-ansible.git
cd k3s-ansible

cat <<EOF > inventory.yaml
---
k3s_cluster:
  children:
    server:
      hosts:
        10.0.0.20:
    agent:
      hosts:
        10.0.0.21:
        10.0.0.22:
        10.0.0.23:
        10.0.0.24:
        10.0.0.25:
        10.0.0.26:

  # Required Vars
  vars:
    ansible_port: 22
    ansible_user: ubuntu
    k3s_version: v1.29.3+k3s1
    api_endpoint: "{{ hostvars[groups['server'][0]]['ansible_host'] | default(groups['server'][0]) }}"
    extra_server_args: "--prefer-bundled-bin --tls-san 192.168.178.3 --flannel-backend=wireguard-native"
    extra_agent_args: ""
    systemd_dir: /etc/systemd/system
    airgap_dir: /root/workspace/proxmox-k8s-playbook/k3s/k3s-ansible/airgap
    token: "b0sQRgKp9Xn9xvTDefdTmpqbQnrUze"
EOF

mkdir airgap
wget https://github.com/k3s-io/k3s/releases/download/v1.29.3%2Bk3s1/k3s-airgap-images-amd64.tar.gz -P ./airgap/
wget https://github.com/k3s-io/k3s/releases/download/v1.29.3%2Bk3s1/k3s -P ./airgap/

ansible-playbook playbook/site.yml -i inventory.yaml
