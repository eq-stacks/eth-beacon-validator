# Architectural Decision Record

In this document we will catalog all decisions made regarding the architecture described in this repository's code. At the head of this document are the [Foundational Decisions](#foundational-decisions) that form the cornerstone of the infrastructure, followed by the [Decision Log](#decision-log) which describes the following, more granular decisions made, in chronoloigical order.

**First-order Principles:**
1. High Availability: System performance degradation or downtime simply _can't happen_.
2. The best technology is the least technology.
3. Prefer FOSS over proprietary software.

- [Architectural Decision Record](#architectural-decision-record)
  - [Foundational Decisions](#foundational-decisions)
    - [Operating System: Linux](#operating-system-linux)
    - [Linux Distribution: Debian Based, Ubuntu Server preferred](#linux-distribution-debian-based-ubuntu-server-preferred)
    - [Local Development & Testing](#local-development--testing)
    - [Infrastructure Management](#infrastructure-management)
    - [Application Management](#application-management)
    - [Security](#security)
    - [Ethereum Clients](#ethereum-clients)
    - [Eth2 Clients](#eth2-clients)
    - [Things we're stuck with](#things-were-stuck-with)
  - [Decision Log](#decision-log)
    - [_2022.01.09_ - Drive Locality](#20220109---drive-locality)
    - [_YYYY.MM.DD_ - Template Decision summary](#yyyymmdd---template-decision-summary)

## Foundational Decisions

### Operating System: Linux

Almost a no-brainer. [Linux](https://www.linux.org/) is chosen over other systems such as BSD, almost entirely due to its ubiquity. All of the software we're going to be relying on is either written on or written for Linux systems and avoiding Linux would be asking for unknown-unknowns.

We don't lose much of anything by using Linux - there may be other esoteric and specialized *nix based that manifest in the future, but those should be evaluated carefully, on a case-by-case basis. 

### Linux Distribution: Debian Based, Ubuntu Server preferred

The described infrastructure targets [Debian Stable](https://www.debian.org/releases/stable/) instead of "derivative" distributions like Ubuntu Server due to its:
- Exceedingly stable LTS, plus 1 additional year of support
- Lightweight footprint, in terms of resource utilization
- Lack of proprietary software in the default package repositories

Default OS-level conventions should be honored, such as `systemd`, `apt`, etc.  

TODOs:
- Compare to Alpine / Rancher / NixOS?

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
| Provisioning | Ansible | TBD | Bash scripts, Vagrant, pyinfra |
| Internal Networking | Wireguard | TBD | OpenVPN, Cloud-specific solutions e.g. Amazon VPC |

Open questions:
1. Are Terraform / Ansible both necessary? It would be great if neither were.
2. Can we get away with something much simpler? Probably not for Cloud management, and better to use these than some vendor-locked-in solution.

### Application Management

Containerization vs Non-containerization discussion

| Function | Chosen Tech | Rationale | Alternatives |
| -------- | ----------- | --------- | ------------ |
| Containerization | Docker | TBD | Podman, Systemd services |
| Container Orchestration | Docker Swarm | TBD | Kubernetes |
| Configuration | TBD | Env vars, docker-compose.yaml, templated files, docker configs |

### Security

| Function | Chosen Tech | Rationale | Alternatives |
| -------- | ----------- | --------- | ------------ |
| Key Management | TBD | TBD | |

### Ethereum Clients

Status: Currently evaluating the Ethereum Foundation's [list of suggested Eth1 clients](https://launchpad.ethereum.org/en/select-client):
1. Nethermind
2. Geth
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


### Things we're stuck with

- InfluxDB (imported from Geth)

## Decision Log

### _2022.01.09_ - Drive Locality

The workloads of both the Eth1 and Eth2 nodes are extremely IO (write) heavy. As such, any latency introduced by
network distance and/or out of date connectors will be a prime factor in system performance. As such, any applications
should be position _as close to_ the drives as possible to minimize any delay.

This can be time-consuming work in a self-hosted setting and could benefit from some benchmarking, but in general
any cloud solution we choose should be able to mitigate this with some easy configuration.

### _YYYY.MM.DD_ - Template Decision summary

Template: In the context of <use case/user story u>, facing <concern c> we decided for <option o> and neglected <other options>, to achieve <system qualities/desired consequences>, accepting <downside d/undesired consequences>, because <additional rationale>.