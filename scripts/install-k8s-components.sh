#!/bin/bash

# shellcheck disable=SC2034
k8s_version="1.19.0-*"
kubectl_version="1.19.4-*"
docker_version="5:19.03.0~3-0~ubuntu-bionic" # 19.03


# Enable IPv4 Forwarding
sudo /bin/su -c "echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf"
sudo sysctl -p
sudo sysctl -a | grep net.ipv4.ip_forward

# kubelet requires swap off
sudo swapoff -a
sed -i '/swap/d' /etc/fstab

# Install master components
sudo apt update
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y

sudo /bin/su -c "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -"
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt-get update -y
sudo apt-get install docker-ce="$docker_version" -y
## to install specific version of docker:
# sudo apt-get install -y docker.io="5:18.09.8~3-0~ubuntu-bionic"
## to get version list:
# apt-cache madison docker-ce
sudo systemctl restart docker && sudo systemctl enable docker
sudo systemctl status docker

sudo /bin/su -c "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -"
sudo echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update -y

sudo apt-get install -y kubeadm="$k8s_version" kubectl="$kubectl_version" kubelet="$k8s_version"

# Disable FW
systemctl stop ufw
systemctl disable ufw

# Fix kubelet IP
eth1=$(ip a s eth1 | egrep -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d' ' -f2)
echo "Environment=\"KUBELET_EXTRA_ARGS=--node-ip=$eth1\"" | sudo tee -a /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo systemctl daemon-reload
sudo systemctl restart kubelet
