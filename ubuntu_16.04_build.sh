#!/bin/bash

# ============================= #
#   Designed for Ubuntu 16.04 
# To build your server for you 
# ============================= #
#
#
#
# ============================= #
# Input your system details here
# ============================= #


HOSTNAME =
SYSTEMIP = 
DOMAIN = 
LANGUAGE = 
CHARSTET = 
SSHPORT = 
USER = 
ADMINEMAIL = 
PUBLICKEY = 

# ============================= #
#      End of manual input
#   Please run script as root
# ============================= #
#
echo "We're making sure the system is updated"
#
aptitude update && aptitude safe-upgrade -y
#
echo "Now we're going to set the hostname"
#
echo "$HOSTNAME" > /etc/hostname
#
echo "Updating hosts filename"
#
mv /etc/hosts /etc/hosts.bak
#
echo "

