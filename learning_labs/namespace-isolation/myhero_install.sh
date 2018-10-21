#! /bin/bash

echo "Installing the MyHero Sample Application"
kubectl -n myhero apply -f myhero_data.yaml
kubectl -n myhero apply -f myhero_mosca.yaml
kubectl -n myhero apply -f myhero_ernst.yaml
kubectl -n myhero apply -f myhero_app.yaml
MYHERO_APP_EXTERNAL_IP=$(kubectl -n myhero get services myhero-app -o json | python -c 'import sys, json; print json.load(sys.stdin)["status"]["loadBalancer"]["ingress"][0]["ip"]')
sed "s/<PROVIDE-EXTERNAL-IP-FOR-myhero-app>/${MYHERO_APP_EXTERNAL_IP}/" myhero_ui.yaml > myhero_ui_ready.yaml

kubectl -n myhero apply -f myhero_ui_ready.yaml
