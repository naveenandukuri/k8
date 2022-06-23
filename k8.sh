#!/bin/bash
#use t2 medium, ubuntu 20.04
sudo apt-get update

#install docker 
sudo apt-get install docker.io -y

#install packages needed to use k8's apt repository
sudo apt-get install apt-transport-https ca-certificates curl -y

# download the google cloud public signing key
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# add the k8's apt repository
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

#update the apt package and install kubectl, kubeadm
sudo apt-get update
sudo apt-get install kubelet kubectl kubeadm -y

# install the k8's networking model calico
sudo kubeadm init --node-name master --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=`hostname -I | awk '{print $1}'`

#ownership for kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#Install tigera calico operator and custom resource definition
kubectl create -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml
kubectl create -f https://projectcalico.docs.tigera.io/manifests/custom-resources.yaml

#remove the taints on the master so that you can schedule the pods on it
kubectl taint nodes --all node-role.kubernetes.io/control-plane- node-role.kubernetes.io/master-

#confirm that all pods are running or not
watch kubectl get pods -n calico-system
#wait for few seconds to initialize the calico containers
