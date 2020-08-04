#!/bin/bash
#
# FileName: startNM.sh
# Author:   Brannon Fay
# Created:  July 14, 2020
#	 
# Description: Start Network Manager service. Upon wifi not running
#		found this was needed to get it going.
#
# TODO: Ansiblize this script
#
#

sudo systemctl start NetworkManager.service
sudo systemctl enable NetworkManager.service
