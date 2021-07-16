#!/bin/bash

if [ ! -d /var/share ]
then
    echo "share dir: '/var/share' NOT found !"
    exit 1
fi


if [ -f /var/share/join_command.sh ]
then
   sh /var/share/join_command.sh
else
  echo "'/var/share/join_command.sh' file NOT found"
  exit 1
fi
