#!/bin/bash
s1=$(sudo md5sum '/etc/hosts' | cut -d ' ' -f 1)
s2=$(sudo md5sum '/var/share/hosts' | cut -d ' ' -f 1)
if ! [ "$s1" = "$s2" ]
    then
    sudo scp /var/share/hosts /etc/hosts
    echo "master: /etc/hosts updated successfully"
fi