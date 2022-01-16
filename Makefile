build:
	minikube start --cpus 4 --memory 6144 --nodes 1 -p eth-beacon-chain
	kubectl apply -f validators-namespace.yml
	kubectl apply -n validators -f stacks/geth
	kubectl apply -n validators -f stacks/nimbus

logs:
	kubectl -n validators logs goerli-geth-0

geth:
	kubectl -n validators exec -ti goerli-geth-0 -- /bin/sh # geth attach --datadir=/root/.ethereum/goerli

nimbus:
	kubectl -n validators exec -ti prater-nimbus-0 -- /bin/bash

init:
	minikube -p eth-beacon-chain addons enable ingress

restart:
	kubectl -n validators rollout restart sts goerli-geth

getall:
	kubectl -n validators get all

clean:
	minikube stop -p eth-beacon-chain
	minikube delete -p eth-beacon-chain