#! /bin/bash

echo "Installing the MyHero Sample Application"
kubectl apply -f myhero_data.yaml
kubectl apply -f myhero_mosca.yaml
kubectl apply -f myhero_ernst.yaml
kubectl apply -f myhero_app.yaml

# Retrieve the EXTERNAL-IP for the myhero-app service
MYHERO_APP_EXTERNAL_IP=$(kubectl get services myhero-app -o json | python -c 'import sys, json; print json.load(sys.stdin)["status"]["loadBalancer"]["ingress"][0]["ip"]')

# Update the application defintion for myhero-ui with the EXTERNAL-IP
sed "s/<PROVIDE-EXTERNAL-IP-FOR-myhero-app>/${MYHERO_APP_EXTERNAL_IP}/" myhero_ui.yaml > myhero_ui_ready.yaml

kubectl apply -f myhero_ui_ready.yaml
