#!/bin/bash

wget -O helm.tar.gz https://get.helm.sh/helm-v3.6.0-linux-amd64.tar.gz

tar -zxvf helm.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm

rm linux-amd64 -rf
rm helm.tar.gz -rf

# Validate
helm