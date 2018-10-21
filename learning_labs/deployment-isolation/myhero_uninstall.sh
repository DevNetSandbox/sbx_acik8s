#! /bin/bash

echo "Uninstalling the MyHero Demo Application"
kubectl -n myhero delete service myhero-ui
kubectl -n myhero delete service myhero-app
kubectl -n myhero delete service myhero-data
kubectl -n myhero delete service myhero-mosca

kubectl -n myhero delete deployment myhero-ui
kubectl -n myhero delete deployment myhero-app
kubectl -n myhero delete deployment myhero-ernst
kubectl -n myhero delete deployment myhero-mosca
kubectl -n myhero delete deployment myhero-data
