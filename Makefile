build: prometheus
	kubectl apply -f geth -f besu -f nethermind -f openethereum

init:
	kubectl create namespace validators
	kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
	kubectl patch storageclass premium-rwo -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
	kubectl apply -f ./scripts/volumesnapshotclass.yml
	helm install --namespace default prometheus prometheus-community/kube-prometheus-stack
	kubectl apply -f metrics/ingress.yml

clean: confirm
	kubectl delete -f metrics/ingress.yml
	helm uninstall prometheus
	kubectl delete crd alertmanagerconfigs.monitoring.coreos.com
	kubectl delete crd alertmanagers.monitoring.coreos.com
	kubectl delete crd podmonitors.monitoring.coreos.com
	kubectl delete crd probes.monitoring.coreos.com
	kubectl delete crd prometheuses.monitoring.coreos.com
	kubectl delete crd prometheusrules.monitoring.coreos.com
	kubectl delete crd servicemonitors.monitoring.coreos.com
	kubectl delete crd thanosrulers.monitoring.coreos.com
	kubectl delete -f ./scripts/volumesnapshotclass.yml
	kubectl patch storageclass premium-rwo -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
	kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
	kubectl delete namespace validators

confirm:
	echo "This will delete everything. There is no undo. Giving you 3 seconds to reconsider..."
	sleep 3 

.PHONY: build init clean confirm