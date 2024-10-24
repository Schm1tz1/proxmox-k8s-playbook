# k3s with Cilium

* Straightforward setup, just follow `setup_k3s_cilium.sh`
* Important: Make sure that the default Cilium CIDR (10.0.0.0/8) is not in conflict with your network. I learned the hard way... In case you run into conflicts, overrride the dafeults with the helm values:
```
ipam.operator.clusterPoolIPv4PodCIDRList=10.42.0.0/16
ipv4NativeRoutingCIDR=10.42.0.0/16
```
