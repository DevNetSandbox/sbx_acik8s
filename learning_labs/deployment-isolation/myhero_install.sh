#! /bin/bash

echo "What is your Pod Number? "
read POD_NUM
echo "Pod Num: ${POD_NUM}"

sed "s/kubesbxXX/kubesbx${POD_NUM}/" myhero_data.template > myhero_data.yaml
sed "s/kubesbxXX/kubesbx${POD_NUM}/" myhero_mosca.template > myhero_mosca.yaml
sed "s/kubesbxXX/kubesbx${POD_NUM}/" myhero_ernst.template > myhero_ernst.yaml
sed "s/kubesbxXX/kubesbx${POD_NUM}/" myhero_app.template > myhero_app.yaml

echo "Installing the MyHero Sample Application"
kubectl -n myhero apply -f myhero_data.yaml
kubectl -n myhero apply -f myhero_mosca.yaml
kubectl -n myhero apply -f myhero_ernst.yaml
kubectl -n myhero apply -f myhero_app.yaml

MYHERO_APP_EXTERNAL_IP=$(kubectl -n myhero get services myhero-app -o json | python -c 'import sys, json; print json.load(sys.stdin)["status"]["loadBalancer"]["ingress"][0]["ip"]')
# echo "AP IP: ${MYHERO_APP_EXTERNAL_IP}"
sed "s/kubesbxXX/kubesbx${POD_NUM}/" myhero_ui.template > myhero_ui.yaml
sed "s/<PROVIDE-EXTERNAL-IP-FOR-myhero-app>/${MYHERO_APP_EXTERNAL_IP}/" myhero_ui.yaml > myhero_ui_ready.yaml

kubectl -n myhero apply -f myhero_ui_ready.yaml
