#!/bin/bash

# IP Range "10.244.0.0/16" is Flannel default range
#sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=10.0.0.10
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$(ip a s eth1 | egrep -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d' ' -f2)

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

mkdir -p /home/vagrant/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown vagrant:vagrant /home/vagrant/.kube/config
sudo chown vagrant:vagrant /home/vagrant/.kube/ -R


# Install Flannel
sudo wget -O kube-flannel.yml https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
sudo  sed -i '/--kube-subnet-mgr$/a \        - --iface=eth1' kube-flannel.yml | grep iface
sudo kubectl apply -f kube-flannel.yml
sudo rm kube-flannel.yml -f

#need to specify eth1 as the port
#https://stackoverflow.com/questions/47845739/configuring-flannel-to-use-a-non-default-interface-in-kubernetes


# Generate join command
#sudo kubeadm token create --print-join-command > /tmp/join-command.txt

echo "master Installation done successfully."
