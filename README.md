# Playbook to install local k8s cluster on Proxmox

## Set Up VMs with Terraform
* add your token, then adapt the configs/variables in [./terraform](./terraform/)
* check with `terraform plan`
* deploy with `terraform apply`

## Installation of different distributions
* k3s - go to [k3s](./k3s/)
* RKE2 - go to [rke2](./rke2/)
* OpenShift (TODO)

## General Kubernetes

### Kubernetes Dashboard
Source: https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
* install dashboard: `kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.0/aio/deploy/recommended.yaml` (also see https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)
* start proxy: `kubectl proxy` and access dashboard via http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
* To create a user/token: 
```
$ cat <<EOF >dashboard-adminuser.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

$ kubectl apply -f dashboard-adminuser.yaml
serviceaccount/admin-user created
clusterrolebinding.rbac.authorization.k8s.io/admin-user created

$ kubectl -n kubernetes-dashboard create token admin-user
(...)
```
Copy & Paste the token into the token field on login. 
(https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md)
