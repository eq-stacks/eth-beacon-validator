# Architectural Decision Record

In this document we will catalog all decisions made regarding the architecture described in this repository's code. At the head of this document are the [Foundational Decisions](#foundational-decisions) that form the cornerstone of the infrastructure, followed by the [Decision Log](#decision-log) which describes the following, more granular decisions made, in chronoloigical order.

**First-order Principles:**
1. Validation is a highly competitive practice. The higher you are on the leaderboard the better
2. In general, your validator ranking depends on *high availability* and *low latency*
3. Low Latency = High network throughput, high disk speed
4. The best technology is the least technology
5. Prefer FOSS over proprietary software

- [Architectural Decision Record](#architectural-decision-record)
  - [Foundational Decisions](#foundational-decisions)
    - [Operating System: Linux](#operating-system-linux)
    - [Linux Distribution: Container-Optimized OS from Google](#linux-distribution-container-optimized-os-from-google)
    - [Local Development & Testing](#local-development--testing)
    - [Infrastructure Management](#infrastructure-management)
    - [Application Management](#application-management)
    - [Security](#security)
    - [Ethereum Clients](#ethereum-clients)
    - [Eth2 Clients](#eth2-clients)
  - [Decision Log](#decision-log)
    - [_2022.01.22_ - Ephemeral Storage + Google Cloud Volume Snapshots](#20220122---ephemeral-storage--google-cloud-volume-snapshots)
    - [_2022.01.22_ - Google Cloud](#20220122---google-cloud)
    - [_2022.01.11_ - Don't submit the deposit before your validator is fully synced.](#20220111---dont-submit-the-deposit-before-your-validator-is-fully-synced)
    - [_2022.01.10_ - The Prater Testnet](#20220110---the-prater-testnet)
    - [_2022.01.09_ - Drive Locality](#20220109---drive-locality)
    - [_YYYY.MM.DD_ - Template Decision summary](#yyyymmdd---template-decision-summary)

## Foundational Decisions

### Operating System: Linux

Almost a no-brainer. [Linux](https://www.linux.org/) is chosen over other systems such as BSD, almost entirely due to its ubiquity. All of the software we're going to be relying on is either written on or written for Linux systems and avoiding Linux would be asking for unknown-unknowns.

We don't lose much of anything by using Linux - there may be other esoteric and specialized *nix based that manifest in the future, but those should be evaluated carefully, on a case-by-case basis. 

### Linux Distribution: Container-Optimized OS from Google

We are more or less vendor-locked to Container-Optimized OS (COS) due to our use of Google Kubernetes Engine.

[Container-Optimized OS] is based on the [Chromium OS]. Alternatively Google Cloud offers Ubuntu for the
underlying node pool OS. However, COS is [security-hardened] for containers, and is more lightweight than Ubuntu.

[Container-Optimized OS]: https://cloud.google.com/container-optimized-os/docs
[Chromium OS]: https://www.chromium.org/chromium-os
[security-hardened]: https://cloud.google.com/container-optimized-os/docs/concepts/security

### Local Development & Testing

| Function | Chosen Tech | Rationale | Alternatives |
| -------- | ----------- | --------- | ------------ |
| Hypervisor (Linux) | KVM | TBD | |
| Hypervisor (Mac) | HVF | TBD | UTM |
| Virtualization | QEMU | TBD | VirtualBox |

### Infrastructure Management

| Function | Chosen Tech | Rationale | Alternatives |
| -------- | ----------- | --------- | ------------ |
| IT Automation | Terraform | TBD | Bash scripts, Vendor-specific e.g. CloudFormation  |

Open questions:
1. Are Terraform / Ansible both necessary? It would be great if neither were.
2. Can we get away with something much simpler? Probably not for Cloud management, and better to use these than some vendor-locked-in solution.

### Application Management

Containerization vs Non-containerization discussion

| Function | Chosen Tech | Rationale | Alternatives |
| -------- | ----------- | --------- | ------------ |
| Container runtime | Docker | [Soon to be CRI] | Podman, Systemd services |
| Container Orchestration | Kubernetes| Cloud Provider support, eventual push-button deployments | Docker Swarm |
| Configuration | TBD | Env vars, docker-compose.yaml, templated files, docker configs |

[Soon to be CRI]: https://kubernetes.io/blog/2020/12/02/dont-panic-kubernetes-and-docker/

### Security

| Function | Chosen Tech | Rationale | Alternatives |
| -------- | ----------- | --------- | ------------ |
| Key Management | TBD | TBD | |

### Ethereum Clients

Status: Currently evaluating the Ethereum Foundation's [list of suggested Eth1 clients](https://launchpad.ethereum.org/en/select-client):
1. Nethermind
2. Geth - imports InfluxDB
3. Besu
4. Erigon

Note: OpenEthereum has been [deprecated](https://medium.com/openethereum/gnosis-joins-erigon-formerly-turbo-geth-to-release-next-gen-ethereum-client-c6708dd06dd).

### Eth2 Clients

Status: Currently evaluating the Ethereum Foundation's [list of suggested Eth2 clients](https://launchpad.ethereum.org/en/select-client):

1. Prysm
2. Nimbus
3. Teku
4. Lighthouse

https://ethereum.org/en/developers/docs/nodes-and-clients/#clients

## Decision Log

### _2022.01.22_ - Ephemeral Storage + Google Cloud Volume Snapshots

Since the blockchain data is stateful but *not* user-oriented, we don't need to use `StatefulSets` here, nor explicit
`PersistentVolumeClaims`. Instead we can use `ephemeral` volumes described in the pod spec, and periodic `VolumeSnapshots`
can be made to reduce syncing time and resource utilization.

Caveats:
1. The `VolumeSnapshot`s must be manually created one time during startup.
2. RBAC or similar will need to be configured so that we can call the K8S API during a `CronJob`.
3. This disqualified Linode as a cloud provider :(

Also, note that volume snapshots report in GKE as "Ready to Use" even though they're totally not. It really takes
about 15m until they're ready.

```
Status:
  ...
  Ready To Use:                        true
Events:
  Type    Reason            Age    From                 Message
  ----    ------            ----   ----                 -------
  Normal  CreatingSnapshot  6m10s  snapshot-controller  Waiting for a snapshot validators/goerli-openethereum-data-snapshot-latest to be created by the CSI driver.
```

### _2022.01.22_ - Google Cloud

After benchmarking both [network] and [disk] IO, it was determined that Google Cloud engine was the most cost-effective
solution.

[network]: https://www.notion.so/Network-I-O-9499b80dd9ec4d928d91fd3dc971a4f9
[disk]: https://www.notion.so/Disk-I-O-dab9776f66c04aa4b0f46f13c8b58ecf

### _2022.01.11_ - Don't submit the deposit before your validator is fully synced.

The beacon chain's validation system is based on the concept of periodic [epochs and slots]. Slots every 12 seconds, and your validator is expected to _attest_ every ten slots or so (given by `nextActionWait`  in the `slot end` event in the logs). If your node is still syncing, has low peers, or is otherwise downgraded, there is a chance that it will miss attestations. *Missing attestations will result in a lower ranking on the validator leaderboard.*

Thus, wait until the node is stable to make the deposit that turns it from a client into a validator.

[epochs and slots]: https://ethos.dev/beacon-chain/

### _2022.01.10_ - The Prater Testnet

There are currently two primary testnets for Eth2: Pyrmont and Prater. We will test on Prater

Reasoning:
1. Prater is officially represented by an Ethereum Foundation subdomain
2. Prater is meant to be the successor of Pyrmont
3. Prater's purpose is to emulate 2x the amount of mainnet traffic to stress-test validator implementations

### _2022.01.09_ - Drive Locality

The workloads of both the Eth1 and Eth2 nodes are extremely IO (write) heavy. As such, any latency introduced by
network distance and/or out of date connectors will be a prime factor in system performance. As such, any applications
should be position _as close to_ the drives as possible to minimize any delay.

This can be time-consuming work in a self-hosted setting and could benefit from some benchmarking, but in general
any cloud solution we choose should be able to mitigate this with some easy configuration.

### _YYYY.MM.DD_ - Template Decision summary

Template: In the context of <use case/user story u>, facing <concern c> we decided for <option o> and neglected <other options>, to achieve <system qualities/desired consequences>, accepting <downside d/undesired consequences>, because <additional rationale>.