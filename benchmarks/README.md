# Benchmarks

## Disk IO (dbench)

From the project root:

```bash
$ kubectl apply -f benchmarks/dbench.yml
```

Then, use `kubectl logs` to monitor.

## Network IO (iperf)

From the project root:

```bash
$ git clone https://github.com/InfraBuilder/k8s-bench-suite knb
$ ./knb/knb --verbose \
    --client-node `kubectl get nodes --no-headers -o=custom-columns=":metadata.name" | head -1` \
    --server-node `kubectl get nodes --no-headers -o=custom-columns=":metadata.name" | head -2 | tail -1`
```