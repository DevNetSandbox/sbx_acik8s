#! /bin/bash

# kubectl apply -f myhero_data.yaml
# kubectl apply -f myhero_mosca.yaml
# kubectl apply -f myhero_ernst.yaml
# kubectl apply -f myhero_app.yaml

MYHERO_APP_EXTERNAL_IP=$(kubectl describe service myhero-app | awk '/LoadBalancer Ingress:/ {print $3}')


echo "AP IP: ${MYHERO_APP_EXTERNAL_IP}"
