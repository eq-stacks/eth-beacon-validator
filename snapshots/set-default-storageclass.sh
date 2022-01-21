#!/bin/bash

kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass premium-rwo -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'