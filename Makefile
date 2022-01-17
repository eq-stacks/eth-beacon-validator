build:
	kubectl create namespace validators
	kubectl apply -f geth -f besu -f nethermind

logs:
	kubectl -n validators logs goerli-geth-0

prometheus:
	helm install prometheus prometheus-community/kube-prometheus-stack

firewall-gcloud:
	gcloud compute firewall-rules create grafanatcp --allow tcp:30080
	gcloud compute firewall-rules create rlpx1tcp --allow tcp:30303
	gcloud compute firewall-rules create rlpx1udp --allow udp:30303
	gcloud compute firewall-rules create rlpx2tcp --allow tcp:30304
	gcloud compute firewall-rules create rlpx2udp --allow udp:30304
	gcloud compute firewall-rules create rlpx3tcp --allow tcp:30305
	gcloud compute firewall-rules create rlpx3udp --allow udp:30305

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
