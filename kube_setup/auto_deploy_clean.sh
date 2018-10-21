#! /bin/bash

# Script to Automatically Reset the DevNet ACI/Kubernetes Sandbox

# Notes on how to use this script
# 1. Start VPN and ssh to the Devlopment Workstation in the pod
# 2. Set session environment variable (for convenience)
#   export POD_NUM=??
#   export POD_PASS=??????
# 3. Run the script
#   ./auto_deploy_clean.sh ${POD_NUM} ${POD_PASS}


POD_NUM=$1
POD_PASS=$2

echo "Auto Reset of Kubernetes with ACI CNI Sandbox requested for: "
echo "Pod Number: ${POD_NUM}"
echo "Pod Password: ${POD_PASS}"

if [ -z ${POD_NUM} ] || [ -z ${POD_PASS} ]
then
  echo "You mush provide a pod number and pod password."
  echo " ./auto_deploy_clean.sh POD_NUM POD_PASS"
  exit
fi

# Final confirmation before beginning
echo "This process will delete any exisiting Kubernetes cluster currently configured, "
echo "clear SSH authentication keys between DevBox and nodes, and delete code repo from DevBox."
echo "Would you like to continue? [yes/no] "
read CONFIRM
if [ ${CONFIRM} != "yes" ]
then
  echo "Auto Deployment Canceled."
  exit
fi

# Activate the venv for the project
source ../venv/bin/activate

ansible-playbook -i inventory/sbx${POD_NUM}-hosts \
  -e "ansible_ssh_pass=${POD_PASS}" \
  kube_reset.yaml

ansible-playbook -i inventory/sbx${POD_NUM}-hosts \
  -e "ansible_ssh_pass=${POD_PASS}" \
  ssh_authorized_key_clear.yaml

rm -Rf ~/sbx_acik8s
