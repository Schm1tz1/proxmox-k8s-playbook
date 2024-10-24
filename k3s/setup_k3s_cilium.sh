#!/usr/bin/env bash

# Master Node(s)
ssh -o StrictHostKeyChecking=no -l debian 10.0.0.20 'curl -sfL https://get.k3s.io | sudo sh -s - \
  --flannel-backend=none \
  --disable-kube-proxy \
  --disable servicelb \
  --disable-network-policy \
  --disable traefik \
  --tls-san 192.168.178.3 \
  --cluster-init'

ssh -o StrictHostKeyChecking=no -l debian 10.0.0.20 'sudo chmod 600 /etc/rancher/k3s/k3s.yaml'
ssh -o StrictHostKeyChecking=no -l debian 10.0.0.20 'sudo cat /etc/rancher/k3s/k3s.yaml >~/kubeconf'

scp -v debian@10.0.0.20:~/kubeconf ~/.kube/config
sed 's/127.0.0.1/10.0.0.20/g' ~/.kube/config -i
kubectl get svc -A

cilium install \
  --set kubeProxyReplacement=true \
  --set k8sServiceHost=10.0.0.20 \
  --set k8sServicePort=6443 \
  --set ipam.operator.clusterPoolIPv4PodCIDRList="10.42.0.0/16" \
  --set ipv4NativeRoutingCIDR=10.42.0.0/16 \
  --set ipv4.enabled=true \
  --helm-set operator.replicas=1 

cilium status --wait

K3S_TOKEN=$(ssh -o StrictHostKeyChecking=no -l debian 10.0.0.20 'sudo cat /var/lib/rancher/k3s/server/token')

# Worker Nodes
for i in $(seq 21 26); do
  ssh -o StrictHostKeyChecking=no -l debian 10.0.0.$i "curl -sfL https://get.k3s.io | sh -s - agent \
    --token "${K3S_TOKEN}" \
    --server \"https://10.0.0.20:6443\""
done
