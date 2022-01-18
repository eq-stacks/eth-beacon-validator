build: prometheus
	kubectl create namespace validators
	kubectl apply -f geth -f besu -f nethermind -f openethereum
	kubectl apply -f metrics/ingress.yml

logs:
	kubectl -n validators logs goerli-geth-0

prometheus:
	helm install prometheus prometheus-community/kube-prometheus-stack

clean: prometheus-install

prometheus-uninstall:
	helm uninstall prometheus
	kubectl delete crd alertmanagerconfigs.monitoring.coreos.com
	kubectl delete crd alertmanagers.monitoring.coreos.com
	kubectl delete crd podmonitors.monitoring.coreos.com
	kubectl delete crd probes.monitoring.coreos.com
	kubectl delete crd prometheuses.monitoring.coreos.com
	kubectl delete crd prometheusrules.monitoring.coreos.com
	kubectl delete crd servicemonitors.monitoring.coreos.com
	kubectl delete crd thanosrulers.monitoring.coreos.com

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
