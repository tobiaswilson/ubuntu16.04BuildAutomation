#!/bin/bash

#Important notes:

# Run script as root
# Navigate to desired folder and type:
# git pull https://github.com/tobiaswilson/ubuntu_16.04_build
# ./[scriptname].sh to run script
# Please input your values first before running the script


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
apt-get update && apt-get safe-upgrade -y
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
127.0.0.1       localhost
$SYSTEMIP       $HOSTNAME.$DOMAIN     $HOSTNAME
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
" >> /etc/hosts

apt-get install openssh-server -y

# ============================= #
#         SSH Security
# ============================= #

echo "Changing SSH port if required"

sed -i "s/Port 22/Port $SSHPORT/g" /etc/ssh/sshd_config

echo "Disabling root login"

sed -i "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config

#  echo "Disabling password authentication"

#  sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config


# -------------------------------------------------------------------------
# Script to add a user to Linux system
# -------------------------------------------------------------------------
# Copyright (c) 2007 nixCraft project <http://bash.cyberciti.biz/>
# -------------------------------------------------------------------------
if [ $(id -u) -eq 0 ]; then
	# read -p "Enter username of who can connect via SSH: " USER
	read -s -p "Enter password of user who can connect via SSH: " PASSWORD
	egrep "^$USER" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "$USER exists!"
		exit 1
	else
		pass=$(perl -e 'print crypt($ARGV[0], "password")' $PASSWORD)
		useradd -s /bin/bash -m -d /home/$USER -U -p $pass $USER
		[ $? -eq 0 ] && echo "$USER has been added to system!" || echo "Failed to add a $USER!"
	fi
else
	echo "Only root may add a user to the system"
	exit 2
fi
# -------------------------------------------------------------------------
# End script to add a user to Linux system
# -------------------------------------------------------------------------
#

echo adding user to SSH AllowUsers

echo "AllowUsers $USER" >> /etc/ssh/sshd_config

echo "Adding $USER to sudo users"

cp /etc/sudoers /etc/sudoers.tmp
chmod 0640 /etc/sudoers.tmp
echo "$USER    ALL=(ALL) ALL" >> /etc/sudoers.tmp
chmod 0440 /etc/sudoers.tmp
mv /etc/sudoers.tmp /etc/sudoers

echo "Adding ssh key"
#
mkdir /home/$USER/.ssh
touch /home/$USER/.ssh/authorized_keys
echo $PUBLICKEY >> /home/$USER/.ssh/authorized_keys
chown -R $USER:$USER /home/$USER/.ssh
chmod 700 /home/$USER/.ssh
chmod 600 /home/$USER/.ssh/authorized_keys
#
sed -i "s/#AuthorizedKeysFile/AuthorizedKeysFile/g" /etc/ssh/sshd_config
#
/etc/init.d/ssh restart
