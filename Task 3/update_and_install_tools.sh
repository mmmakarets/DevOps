#!/bin/bash

# Update all packages and install most common tools
# Author: Makarets Maryna

if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
    exit
else
    echo "Current user is $(whoami)"
    OS_NAME=$(cat /etc/os-release | grep PRETTY_NAME)
    echo $OS_NAME
    read -t 5 -p "Continue in 5 seconds..."

    apt update -y && apt upgrade -y
    apt install -y git-core python3 openssh-server mc htop net-tools telnet
fi