#!/bin/sh
#
# Name: Setup Swap
# Desc: How to increase swap on Small Systems
# Author: Brannon Fay
#
# TODO: Convert to Ansible
#

sudo swapon --show
# if less than 8G, proceed

# Allocate amount needed to get to 8G
sudo fallocate -l 7G /swapfile

sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# add: /swapfile swap swap defaults 0 0
sudo vi /etc/fstab

# Confirm 8G in new swapfile
sudo swapon --show

# Confirm swapiness
cat /proc/sys/vm/swappiness

# If set to default of 60%, update to not be so swappy
#sudo sysctl vm.swappiness=33
#Found this to cause my machine with 4G to become sluggish quickly and changed to go the other way
sudo sysctl vm.swappiness=75

# Make change persist, changing vm.swappiness=60 to desired value
sudo vi /etc/sysctl.conf

# Confirm value is set and if old swap is still present
sudo swapon --show

# Turn off old swap
# Make take time to move current stuff out of swap to new swapfile
sudo swapoff -v /dev/dm-1

# Remove old swap mount from permanent/boot resilience
vi /etc/fstab

# Confirm everything is moved and old swap is no longer active
sudo swapon --show

# Remove old swap mount
sudo rm /dev/dm-1

