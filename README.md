# IaC: Eth Beacon Chain Validator
> Infrastrucutre-as-Code for running an Ethereum 2.0 Beacon Chain Validator

## Install

### Prerequisites

- One or more machines that can run [Kubernetes] (or [minikube] locally)
- Roughly 1 TB of SSD storage for chain data
- Ports 30303 and 9000 open
- (Optional) Static IP address

[Kubernetes]: https://kubernetes.io/docs/tasks/tools/
[minikube]: https://minikube.sigs.k8s.io/docs/start/

### Local installation

Once the prerequisites are in place, simply run `make` to start the minikube cluster and apply the
configuration for geth and nimbus.

```
make
```