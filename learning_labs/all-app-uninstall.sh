#! /bin/bash

echo "This script will uninstall all demo applications used in the labs"
echo "it is provided as a convenience step to prep for a lab step."
echo " "
echo "If an application is NOT currently installed, the script will report "
echo "errors.  This is expected."
echo " "

echo "Uninstalling the Guestbook Application from the default Namespace"
kubectl delete service redis-master
kubectl delete service redis-slave
kubectl delete service frontend
kubectl delete deployment frontend
kubectl delete deployment redis-master
kubectl delete deployment redis-slave

echo "Uninstalling the MyHero Application from the default namespace "
kubectl delete service myhero-ui
kubectl delete service myhero-app
kubectl delete service myhero-data
kubectl delete service myhero-mosca
kubectl delete deployment myhero-ui
kubectl delete deployment myhero-app
kubectl delete deployment myhero-ernst
kubectl delete deployment myhero-mosca
kubectl delete deployment myhero-data

echo "Uninstalling the MyHero Application from the myhero namespace "
kubectl -n myhero delete service myhero-ui
kubectl -n myhero delete service myhero-app
kubectl -n myhero delete service myhero-data
kubectl -n myhero delete service myhero-mosca

kubectl -n myhero delete deployment myhero-ui
kubectl -n myhero delete deployment myhero-app
kubectl -n myhero delete deployment myhero-ernst
kubectl -n myhero delete deployment myhero-mosca
kubectl -n myhero delete deployment myhero-data
