#! /bin/bash

# Script to Automatically Setup the DevNet ACI/Kubernetes Sandbox to different
# states.

# Notes on how to use this script
# 1. Start VPN and ssh to the Devlopment Workstation in the pod
# 2. Set session environment variable (for convenience)
#   export POD_NUM=??
#   export POD_PASS=??????
# 3. Run this command to download and run the auto_deploy.sh script
#   curl -o auto_deploy.sh https://raw.githubusercontent.com/DevNetSandbox/sbx_acik8s/auto_deploy/kube_setup/auto_deploy.sh && chmod +x auto_deploy.sh && ./auto_deploy.sh ${POD_NUM} ${POD_PASS} full

POD_NUM=$1
POD_PASS=$2

# DEPLOY_PHASE will determine which stages to deploy
#  Stages are cumulative, running the steps before
#    1) devbox  - Just prepare the DevBox
#    2) network - Configure the network plumbing on Kubernetes Nodes
#    3) prereq  - Prepare Kubernetes Nodes for cluster setup
#    4) k8s     - Setup new Kubernetes Cluster
#    5) cni     - Install ACI CNI plug-in to Kubernetes
#    x) full    - Full setup (functionally same as previous stage)
DEPLOY_PHASE=$3

# Verify required inputs have been provided
if [ -z ${POD_NUM} ] || [ -z ${POD_PASS} ] || [ -z ${DEPLOY_PHASE} ]
then
  echo "You mush provide a pod number and pod password."
  echo " ./auto_deploy.sh POD_NUM POD_PASS DEPLOY_PHASE"
  echo " "
  echo "Possible Stages are: "
  echo "   Stages are cumulative, running the steps before "
  echo "    1) devbox  - Just prepare the DevBox "
  echo "    2) network - Configure the network plumbing on Kubernetes Nodes"
  echo "    3) prereq  - Prepare Kubernetes Nodes for cluster setup "
  echo "    4) k8s     - Setup new Kubernetes Cluster"
  echo "    5) cni     - Install ACI CNI plug-in to Kubernetes"
  echo "    x) full    - Full setup (functionally same as previous stage)"
  exit
fi

echo "Auto Deployment of Kubernetes with ACI CNI Sandbox requested for: "
echo "  Pod Number: ${POD_NUM}"
echo "  Pod Password: ${POD_PASS}"

# Verify a valid deploy phase was provided
case ${DEPLOY_PHASE} in
  devbox|network|prereq|k8s|cni|full) echo "Deploy Stage: ${DEPLOY_PHASE}";;
  *) echo "  Requested Deploy Stage of '${DEPLOY_PHASE}' not valid"; exit;
esac

# Final confirmation before beginning
echo "Would you like to continue? [yes/no] "
read CONFIRM
if [ ${CONFIRM} != "yes" ]
then
  echo "Auto Deployment Canceled."
  exit
fi

echo "Beginning Auto Deployment of Kubernetes with ACI CNI Sandbox."
echo " "

# prints colored text
success () {
    COLOR="92m"; # green
    STARTCOLOR="\e[$COLOR";
    ENDCOLOR="\e[0m";
    printf "$STARTCOLOR%b$ENDCOLOR" "done\n";
}

# Stage 1) devbox Basic DevBox Setup
echo "Setup DevBox with Development Tools and Repos"
sudo yum install -y wget git nano sshpass >> ~/auto_deploy.log 2>&1
wget https://bootstrap.pypa.io/get-pip.py  >> ~/auto_deploy.log 2>&1
sudo python get-pip.py  >> ~/auto_deploy.log 2>&1
rm get-pip.py  >> ~/auto_deploy.log 2>&1
sudo pip install virtualenv  >> ~/auto_deploy.log 2>&1

git clone https://github.com/DevNetSandbox/sbx_acik8s ~/sbx_acik8s >> ~/auto_deploy.log 2>&1
cd ~/sbx_acik8s >> ~/auto_deploy.log 2>&1

virtualenv venv >> ~/auto_deploy.log 2>&1
source venv/bin/activate >> ~/auto_deploy.log 2>&1
pip install -r kube_setup/requirements.txt  >> ~/auto_deploy.log 2>&1

success
echo " "

echo "Create and deploy RSA keys for passwordless login to pod nodes from DevBox"
cd ~/sbx_acik8s/kube_setup
ansible-playbook -i inventory/sbx${POD_NUM}-hosts \
  -e "ansible_ssh_pass=${POD_PASS}" \
  ssh_authorized_key_setup.yaml  >> ~/auto_deploy.log 2>&1
if [ $? -ne 0 ]
then
  echo "Problem"
  exit 1
fi
success
echo " "

# echo "Run kube_devbox_setup.yml"
echo "Installing Kubernetes admin tools onto DevBox"
ansible-playbook -i inventory/sbx${POD_NUM}-hosts \
  kube_devbox_setup.yml  >> ~/auto_deploy.log 2>&1
if [ $? -ne 0 ]
then
  echo "Problem"
  exit 1
fi
success
echo " "

# End if this stage was requested
if [ ${DEPLOY_PHASE} == "devbox" ]
then
  echo "Requested Phase 'devbox' complete."
  exit
fi

# Stage 2) network - Setup Network Plumbing on Kubernetes Nodes
# echo "Run kube_network_prep.yaml"
echo "Configuring Linux network plumbing on Kubernetes nodes."
ansible-playbook -i inventory/sbx${POD_NUM}-hosts \
  kube_network_prep.yaml  >> ~/auto_deploy.log 2>&1
if [ $? -ne 0 ]
then
  echo "Problem"
  exit 1
fi
success
echo " "

# End if this stage was requested
if [ ${DEPLOY_PHASE} == "network" ]
then
  echo "Requested Phase 'network' complete."
  exit
fi

# Stage 3) prereq - Install prereqs for Kubernetes and prep Linux
# echo "Run kube_prereq_install.yml"
echo "Installing prerequisites and preparing Linux on Kuberentes nodes."
ansible-playbook -i inventory/sbx${POD_NUM}-hosts \
  kube_prereq_install.yml  >> ~/auto_deploy.log 2>&1
if [ $? -ne 0 ]
then
  echo "Problem"
  exit 1
fi
success
echo " "

# End if this stage was requested
if [ ${DEPLOY_PHASE} == "prereq" ]
then
  echo "Requested Phase 'prereq' complete."
  exit
fi

# Stage 4) k8s - Setup a new Kubernetes Cluster
# echo "Run kube_install.yaml"
echo "Setting up a new Kubernetes Cluster on Kubernetes nodes."
ansible-playbook -i inventory/sbx${POD_NUM}-hosts \
  --extra-vars "POD_NUM=${POD_NUM}" \
  kube_install.yaml >> ~/auto_deploy.log 2>&1
if [ $? -ne 0 ]
then
  echo "Problem"
  exit 1
fi
success
echo " "

# End if this stage was requested
if [ ${DEPLOY_PHASE} == "k8s" ]
then
  echo "Requested Phase 'k8s' complete."
  exit
fi

# Stage 5) cni - Install ACI CNI plug-in for Kubernetes
echo "Installing the ACI CNI plug-in for Kuberentes"
cd ~/sbx_acik8s/kube_setup/aci_setup/sbx${POD_NUM}
kubectl apply -f aci-containers.yaml  >> ~/auto_deploy.log 2>&1
if [ $? -ne 0 ]
then
  echo "Problem"
  exit 1
fi
success
echo " "

# End if this stage was requested
if [ ${DEPLOY_PHASE} == "cni" ]
then
  echo "Requested Phase 'cni' complete."
  exit
fi




# End if this stage was requested
if [ ${DEPLOY_PHASE} == "full" ]
then
  echo "Requested Phase 'full' complete."
  exit
fi
