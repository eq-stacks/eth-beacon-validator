build: prometheus
	kubectl create namespace validators
	kubectl apply -f geth -f besu -f nethermind -f openethereum
	kubectl apply -f metrics/ingress.yml

clean: prometheus-uninstall

prometheus:
	helm install --namespace default prometheus prometheus-community/kube-prometheus-stack

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

dbench:
	# edit storage class name first!
	kubectl apply -f benchmarks/dbench.yml

.PHONY: build clean prometheus prometheus-uninstall