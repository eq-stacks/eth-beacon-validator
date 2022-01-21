# IaC: Eth Beacon Chain Validator
> Infrastructure-as-Code for running an Ethereum 2.0 Beacon Chain Validator

Note that while we avoid it when we can, these configurations favor Google Cloud Platform,
where we deploy our production validators.

## Install

### Prerequisites

You will need `kubectl` access to a k8s cluster. The configuration and idioms are geared towards
Google Cloud Engine, but they should be fairly interoperable with other providers or local development
e.g. [`minikube`]

[`kubectl`]: https://kubernetes.io/docs/tasks/tools/
[`minikube`]: https://minikube.sigs.k8s.io/docs/start/

### Initializiation (first time only)

Once you have your cluster ready, run this command to perform a one-time setup:

```
make init
```

This command performs the following tasks:

1. Creates the `validators` namespace
2. Sets `premium-rwo` to the default storage class
3. Creates the `gke-snapshotclass` VolumeSnapshotClass
4. Installs the Prometheus Operator
5. Creates Ingresses for the Prometheus and Grafana UIs

### Running a validator

```
kubectl apply -f geth -f nimbus
```