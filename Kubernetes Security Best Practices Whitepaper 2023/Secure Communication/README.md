
here i have some examples in mind, i'm not sure which one is the best

the provided kind config gives a cluster without a CNI, so the next step is to install cilium via helm

1. cilium: encryption on the pod level using cilium with wireguard encryption https://docs.cilium.io/en/stable/security/network/encryption-wireguard/#encryption-wg
2. cilium: running cilium mTLS introduced in 1.14 https://docs.cilium.io/en/stable/network/servicemesh/mutual-authentication/mutual-authentication/#mutual-authentication-and-mtls-background
3. linkerd: running a cluster mTLS with linkerd https://linkerd.io/2.13/features/automatic-mtls/
