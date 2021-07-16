#!/bin/bash

sudo add-apt-repository ppa:vbernat/haproxy-2.3
sudo apt-get update
sudo apt-get -y install haproxy

sudo systemctl start haproxy
sudo systemctl enable haproxy
sudo systemctl status haproxy

