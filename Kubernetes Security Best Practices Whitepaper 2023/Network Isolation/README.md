# Network Isolation


# Example: Multi Level Application Network Policy

Setup Cluster:

`kind create cluster --config kind-config.yaml`

Setup CNI: 

`sh cni.sh`

This will install cilium as the CNI into the cluster.

# References
- https://kubernetes.io/docs/concepts/services-networking/network-policies/
