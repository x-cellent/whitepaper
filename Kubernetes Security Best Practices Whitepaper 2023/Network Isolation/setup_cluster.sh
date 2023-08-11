#!/bin/bash

kind create cluster --config kind-config.yaml

helm repo add cilium https://helm.cilium.io/

helm install cilium cilium/cilium --version 1.14.0 \
   --namespace kube-system \
   --set image.pullPolicy=IfNotPresent \
   --set ipam.mode=kubernetes

kubectl rollout status daemonset -n kube-system cilium

kubectl apply -f namespaces.yaml
kubectl apply -f netpol.yaml
kubectl apply -f mysql-deployment.yaml
kubectl apply -f wordpress-deployment.yaml
