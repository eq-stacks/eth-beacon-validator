#!/bin/bash

kubectl -n validators get persistentvolumeclaims --no-headers -o=custom-columns=":metadata.name" \
| while read -r line ; do
    export PVC_NAME
    export SNAPSHOT_NAME
    export SNAPSHOT_TIME

    PVC_NAME=$(echo "$line")
    SNAPSHOT_NAME=$(echo "$line" | cut -d "-" -f 5,6,7)

    kubectl delete volumesnapshot ${SNAPSHOT_NAME}-snapshot-latest 
    envsubst < ./snapshots/volumesnapshot.template.yml | kubectl apply -f -    
done

