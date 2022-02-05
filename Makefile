build:
	kubectl apply -f validators/namespace.yml -f validators/geth # -f validators/erigon

init:
	kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
	kubectl patch storageclass premium-rwo -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
	kubectl apply -f ./snapshots/volumesnapshotclass.yml
	kubectl apply -f observability/namespace.yml
	helm install --namespace observability prometheus prometheus-community/kube-prometheus-stack
	kubectl apply -f observability/ingress.yml

clean: confirm
	kubectl delete -f observability/ingress.yml
	helm --namespace observability uninstall prometheus
	kubectl delete crd alertmanagerconfigs.monitoring.coreos.com
	kubectl delete crd alertmanagers.monitoring.coreos.com
	kubectl delete crd podmonitors.monitoring.coreos.com
	kubectl delete crd probes.monitoring.coreos.com
	kubectl delete crd prometheuses.monitoring.coreos.com
	kubectl delete crd prometheusrules.monitoring.coreos.com
	kubectl delete crd servicemonitors.monitoring.coreos.com
	kubectl delete crd thanosrulers.monitoring.coreos.com
	kubectl delete -f ./snapshots/volumesnapshotclass.yml
	kubectl patch storageclass premium-rwo -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
	kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
	kubectl delete -f validators/namespace.yml -f observability/namespace.yml

confirm:
	echo "This will delete all K8s infra. There is no undo. Giving you 3 seconds to reconsider..."
	sleep 3 



snapshots:
	./snapshots/create-volume-snapshots.sh

.PHONY: build init clean confirm snapshots
