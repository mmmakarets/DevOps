#!/bin/bash

# Collect information about system
# Author: Makarets Maryna

read -p "This script will collect basic information about system, press [Enter] to continue..."

mkdir systeminfo
cd systeminfo
ip a > ip_info.txt
lscpu > cpu_info.txt
df -h > disk_usage.txt
free -m > ram_usage.txt
who -b -u > current_connections.txt

cat > general_info.txt <<EOF
#hostname
$(hostname -f)

#os-info
$(cat /etc/os-release)

#uptime
$(uptime)
EOF

echo "Done, all information are stored in folder '$(pwd)/systeminfo'"