build:
	minikube start --cpus 2 --memory 4092 --nodes 1 -p eth-beacon-chain
	kubectl apply -f validators-namespace.yml
	kubectl apply -n validators -f stacks/geth

logs:
	kubectl -n validators logs goerli-geth-0

restart:
	kubectl -n validators rollout restart sts goerli-geth

clean:
	minikube stop -p eth-beacon-chain
	minikube delete -p eth-beacon-chain