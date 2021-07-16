#!/bin/bash

# Install nfs server
sudo apt update
sudo apt install nfs-kernel-server

systemctl start nfs-server
systemctl enable nfs-server

# Export a dir
mkdir /var/nfs-share
sudo echo '/var/nfs-share  *(rw)' > /etc/exports
exportfs -arv

# Validate
showmount -e localhost

# So that the nfs operator can permissions to create sub directories
chmod 777 /var/nfs-share/


################   ################  ################


helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner

helm install -n kube-system nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.server=$(ip a s eth1 | egrep -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d' ' -f2) \
    --set nfs.path=/var/nfs-share \
    --set storageClass.defaultClass=true

