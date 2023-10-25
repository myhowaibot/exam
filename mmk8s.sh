#!/bin/bash

echo y | kubeadm reset
read -p "Enter one of your haed master ip: " IP

read -p "Enter one of your master ip: " RIP

kubeadm init --control-plane-endpoint "$IP:6443" --upload-certs --apiserver-advertise-address $RIP --pod-network-cidr 192.168.0.0/16 --image-repository docker.iranrepo.ir/kubesphere --kubernetes-version 1.27.1 


mkdir -p $HOME/.kube
echo yes | sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


kubectl apply -f https://raw.githubusercontent.com/myhowaibot/exam/main/weave.yaml -n kube-system

kubectl get pods -n kube-system -w 
