# IaC: Eth Beacon Chain Validator
> Infrastructure-as-Code for running an Ethereum 2.0 Beacon Chain Validator

Note that while we avoid it when we can, these configurations favor Google Cloud Platform,
where we deploy our production validators.

## Install

### Prerequisites

- One or more machines that can run [Kubernetes] (or [minikube] locally)
- The [gcloud] command line tool (and a working login)

[Kubernetes]: https://kubernetes.io/docs/tasks/tools/
[minikube]: https://minikube.sigs.k8s.io/docs/start/
[gcloud]: https://cloud.google.com/sdk/gcloud

### Local installation

Once the prerequisites are in place, simply run `make` to start the minikube cluster and apply the
configuration for geth and nimbus.

```
make
```

### Environment setup

If you're setting up a new cluster, you'll need to:

1. Set default storage class
2.Create volume snapshots
