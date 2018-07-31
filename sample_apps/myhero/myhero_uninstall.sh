#! /bin/bash

echo "Uninstalling the MyHero Demo Application"
kubectl delete service myhero-ui
kubectl delete service myhero-app
kubectl delete service myhero-data
kubectl delete service myhero-mosca

kubectl delete deployment myhero-ui
kubectl delete deployment myhero-app
kubectl delete deployment myhero-ernst
kubectl delete deployment myhero-mosca
kubectl delete deployment myhero-data
