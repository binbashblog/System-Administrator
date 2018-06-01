#!/bin/bash
#
# This script will be executed *after* all the other init scripts.
# You can put your own initialization stuff in here if you don't
# want to do the full Sys V style init stuff.
#
# First boot configuration v1
# Created by Harpinder Sanghera
#
# Description:
#
# Provides an interactive script run at boot which can then
# delete itself to stop running on subsequent boots.
# This script cleans a vm deployed from a Gold Image vm template
# and prompts the user to provide information to customize it.
#
#
# I have not tested this on RHEL 7, only works on RHEL5/6
#
# For RHEL 7, not only would you need to set up a systemd service,
# you'd also have to change the script to fit systemd and the
# changes to the network stack introduced in RHEL7 onwards.
# Shouldn't be difficult tbh.
# For more information, see https://access.redhat.com/solutions/1163283
# Or try this: https://www.certdepot.net/rhel7-configure-rc-local-service/
#
#
# Usage: 
#
# Stick the contents of this file into /etc/rc3.d/S99local
# symlink to /etc/rc.local (ln-s /etc/rc3.d/S99local /etc/rc.local)
# then copy to /root/update.sh
# copy sysprep.sh to /root/sysprep.sh
# Make both owned by root and executable:
# chmod +x and chown root
# then touch /root/firstrun
# then touch /root/lastrun
# then reboot and it will run
#
# You can just run the relevent section by just keeping the relevent file
# in /root. E.g. To just run the firstrun if statement, just keep /root/firstrun 
# and delete /root/lastrun. Then reboot.
# Useful if you want to change the hostname and networking.
#
# Remove or rename /root/sysprep.sh if you want to keep the existing log files, 
# old kernels, ssh keys, etc (have a look inside it to see what it does).
# Otherwise it will clean it all up.
#
# If you want to just reconfigure the vm but retain the host name and networking
# config, then just ensure /root/lastrun exists and delete /root/firstrun
#
# Enjoy!
#
####################################################################################
touch /var/lock/subsys/local
plymouth quit
if [ -f "/root/firstrun" ] # ensure /root/firstrun exists if you want to run this section
then
	echo "###################################################"
	echo "##           First boot configuration            ##"
	echo "##         Super duper template booter           ##"
	echo "##                 version 1                     ##"
	echo "###################################################"
	echo ""
	echo ""
	echo "Phase One"
	echo "First boot initializing"
	sleep 2
	echo ""
	echo "Preparing VM as new"
	echo ""
	sleep 2
	echo "Are you sure you want to configure this VM as new? (y/n):    "
	read -r answer1
	if [ "$answer1" = n ]
		then
		echo "You have chosen not to configure this VM, this means this VM has already been configured"
		echo "This first boot script will not reappear again"
		sleep 1
		echo "Please Verify the IP Information and Hostname below"
		echo ""
		echo ""
		echo "Hostname set is $(hostname)"
		sleep 2
		echo ""
		echo ""
		echo "Output of ifconfig is as follows"
		echo "==================================================="
		ifconfig -a
		echo "==================================================="
		echo ""
		echo ""
		echo "Do you want to re-run this script next time you reboot? (y/n):    "
		read -r reboot1
		if [ "$reboot1" = n ]
			then
			echo "You have chosen not to run the script on the next reboot"
			sleep 1
			echo "Removing the script so that it won't execute again!"
			echo "If you want to re-run this script at the next boot then do the following:"
			echo "		touch /root/firstrun"
			echo "		touch /root/lastrun"
			echo "		mv -f /tmp/update.sh /root/"
			echo "then reboot and this script will run again"
			rm -f /root/firstrun
			mv -f /root/update.sh /tmp
			rm -f /root/lastrun
			echo "Backup created in /tmp with name update.sh"
			echo ""
		fi # end 're-run script' if statement
		echo "Do you want to reboot now? (y/n):    "
		read -r reboot
			if [ "$reboot" = y ]
				then
				echo "Rebooting...please wait"
				sleep 8
				init 6
			fi # end reboot if statement
	else # else for 'configure this vm as new' if statement
	clear
	echo "###################################################"
	echo "##           First boot configuration            ##"
	echo "##         Super duper template booter           ##"
	echo "##                 version 1                     ##"
	echo "###################################################"
	echo ""
	echo ""
	echo "Phase One"
	echo "You have chosen to configure this VM as new"
	echo "Trashing old config...please wait..."
	echo "..."
	sleep 1
	echo "..."
	sleep 1
	echo "..."
	echo "Trashing old config...done"
	echo ""
	echo "Running sysprep.sh...please wait"
	/root/sysprep.sh -f & wait $!
	echo ""
	echo ""
	echo ""
	sleep 2
	echo "Running sysprep.sh...done"
	sleep 2
	clear
	echo "###################################################"
	echo "##           First boot configuration            ##"
	echo "##         Super duper template booter           ##"
	echo "##                 version 1                     ##"
	echo "###################################################"
	echo ""
	echo ""
	echo "Phase One"
	echo ""
	echo "Removing elevator=noop from bootloader, if it exists"
	sed -e s/elevator=noop//g -i * /boot/grub/grub.conf
	echo "Removing elevator=noop from bootloader...done"
	sleep 2
	echo "Regenerating resolv.conf"
	rm -rf /etc/resolv.conf & wait $!
	touch /etc/resolv.conf & wait $!
	echo "Regenerating resolv.conf...done"
	sleep 2
	touch /etc/sysconfig/network-scripts/ifcfg-eth0 & wait $!
	echo "regenerating ifcfg-eth0"
	echo -e NAME=eth0 >> /etc/sysconfig/network-scripts/ifcfg-eth0 & wait $!
	echo -e HWADDR= >> /etc/sysconfig/network-scripts/ifcfg-eth0 & wait $!
	sed -i '/BOOTPROTO/c\' /etc/sysconfig/network-scripts/ifcfg-eth0 & wait $!
	echo "BOOTPROTO=static" >> /etc/sysconfig/network-scripts/ifcfg-eth0 & wait $!
	echo -e IPADDR= >> /etc/sysconfig/network-scripts/ifcfg-eth0 & wait $!
	echo -e NETMASK= >> /etc/sysconfig/network-scripts/ifcfg-eth0 & wait $!
	echo -e GATEWAY= >> /etc/sysconfig/network-scripts/ifcfg-eth0 & wait $!
	echo "regenerating ifcfg-eth0...done"
	echo ""
	echo "regenerating network file"
	echo -e NETWORKING=yes >> /etc/sysconfig/network & wait $!
	echo -e HOSTNAME= >> /etc/sysconfig/network & wait $!
	echo -e GATEWAY= >> /etc/sysconfig/network & wait $!
	echo -e NOZEROCONF=yes >> /etc/sysconfig/network & wait $!
	echo -e NETWORKING_IPV6=no >> /etc/sysconfig/network & wait $!
	echo "regenerating network file...done"
	sleep 8
	clear
	echo "###################################################"
	echo "##           First boot configuration            ##"
	echo "##         Super duper template booter           ##"
	echo "##                 version 1                     ##"
	echo "###################################################"
	echo ""
	echo ""
	echo "Phase One"
	echo ""
	echo ""
	echo "==================================================="
	echo "Setup the hostname of the server!"
	echo "==================================================="
	echo ""
	echo -n "Enter the FQDN of the server            : "
	read -r NAME
	echo ""
	echo ""
	echo "==================================================="
	echo "Ethernet device eth0 Configuration!"
	echo "==================================================="
	echo ""
	echo -n "Enter the IP address       : "
	read -r IP
	echo -n "Enter the subnet mask      : "
	read -r MASK
	echo -n "Enter the gateway      : "
	read -r GATEWAY
	echo -n "Enter the 1st DNS IP       : "
	read -r DNS1
	echo -n "Enter the 2nd DNS IP       : "
	read -r DNS2
	echo -n "Enter the DNS search suffix	: "
	read -r SEARCH
	echo ""
	echo ""
	echo "Are you sure everything is perfect now? (y/n):    "
	read -r answer
	if [ "$answer" = y ]
		then
		# change hostname
		sed -i '/HOSTNAME/c\' /etc/sysconfig/network
		echo "HOSTNAME=$NAME" >> /etc/sysconfig/network
		hostname "$NAME"
		# Remove UUID
		sed -i '/UUID/c\' /etc/sysconfig/network-scripts/ifcfg-eth0
		# change IP address:
		sed -i '/IPADDR/c\' /etc/sysconfig/network-scripts/ifcfg-eth0
		echo "IPADDR=$IP" >> /etc/sysconfig/network-scripts/ifcfg-eth0
		# change netmask
		sed -i '/NETMASK/c\' /etc/sysconfig/network-scripts/ifcfg-eth0
		echo "NETMASK=$MASK" >> /etc/sysconfig/network-scripts/ifcfg-eth0
		# change gateway
		sed -i '/GATEWAY/c\' /etc/sysconfig/network-scripts/ifcfg-eth0
		echo "GATEWAY=$GATEWAY" >> /etc/sysconfig/network-scripts/ifcfg-eth0
		sed -i '/GATEWAY/c\' /etc/sysconfig/network
		echo "GATEWAY=$GATEWAY" >> /etc/sysconfig/network
		# change dns1 
		sed -i '/DNS1/c\' /etc/sysconfig/network-scripts/ifcfg-eth0
		echo "DNS1=$DNS1" >> /etc/sysconfig/network-scripts/ifcfg-eth0
		# change dns2
		sed -i '/DNS2/c\' /etc/sysconfig/network-scripts/ifcfg-eth0
		echo "DNS2=$DNS2" >> /etc/sysconfig/network-scripts/ifcfg-eth0
		# change dns search suffix
		echo -e search "$SEARCH" >> /etc/resolv.conf
		# change nameserver 1
		echo -e nameserver "$DNS1" >> /etc/resolv.conf
		# change nameserver 2
		echo -e nameserver "$DNS2" >> /etc/resolv.conf
		# change MAC
		MAC=$(/sbin/ifconfig | grep 'eth0' | tr -s ' ' | cut -d ' ' -f5)
		sed -i '/HWADDR/c\' /etc/sysconfig/network-scripts/ifcfg-eth0
		echo "HWADDR=$MAC" >> /etc/sysconfig/network-scripts/ifcfg-eth0
		clear
		echo "###################################################"
		echo "##           First boot configuration            ##"
		echo "##         Super duper template booter           ##"
		echo "##                 version 1                     ##"
		echo "###################################################"
		echo ""
		echo ""
		echo "Phase One"
		echo "New configuration applied!"
		echo ""
		echo ""
		echo "Rebooting to apply changes before proceeding with phase two, please wait!"
		echo "Phase one complete, removing placeholder /root/firstrun"
		echo "If /root/lastrun placeholder exists then Phase two will commence after the reboot"
		rm -rf /root/firstrun
		sleep 8
		init 6
	else
	echo "You said it's not perfect..."
	echo "Restarting Phase One...please wait"
	sleep 8
	clear
	/root/update.sh
	fi # end for 'Everything is perfect' if statement
	fi # end for 'Configure vm as new' if statement
fi # end for '/root/firstrun exists' if statement


if [ -f "/root/lastrun" ] # ensure /root/lastrun exists if you want to run this section
then
	# set the eth0 interface up and restart
	clear
	echo "###################################################"
	echo "##           First boot configuration            ##"
	echo "##         Super duper template booter           ##"
	echo "##                 version 1                     ##"
	echo "###################################################"
	echo ""
	echo ""
	echo "Phase two"
	sleep 1
	echo ""
	echo "Please Verify the below IP Information and Hostname"
	echo ""
	echo "Hostname set is $(hostname)"
	sleep 8
	echo ""
	echo "Output of ifconfig is as follows"
	echo "==================================================="
	ifconfig eth0
	echo "==================================================="
	echo ""
	echo ""
	echo "Take a note of the above details"
	read -p "Press any key to continue...       : " -n 1 -r
	echo ""
	echo ""
	clear
	echo "###################################################"
	echo "##           First boot configuration            ##"
	echo "##         Super duper template booter           ##"
	echo "##                 version 1                     ##"
	echo "###################################################"
	echo ""
	echo ""
	echo "Phase two"
	echo "Do you want to register the system on the RHEL Satellite? (y/n):    "
	read -r rhelsat
	if [ "$rhelsat" = y ]
		then
		echo "Importing keys..."
		echo "Registering on RHELSAT...please wait"
		rpm -i http://rhelsat/pub/rhn-org-trusted-ssl-cert-1.0-1.noarch.rpm & wait $!
		rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release & wait $!
		rpm --import http://rhelsat/pub/gpg/RPM-GPG-KEY-epel6 & wait $!
		rpm --import http://rhelsat/pub/gpg/RPM-GPG-KEY-vmware & wait $!	
		rpm --import http://rhelsat/pub/gpg/RPM-GPG-KEY-puppetlabs & wait $!
		sleep 1
		echo "Is this a DEV system?  If no, PROD key will be used (y/n)	"	
		read -r dev
		if [ "$dev" = y ]
		then
		echo "Registering on RHELSAT using DEV activation key...please wait"
		rhnreg_ks --activationkey=11-puppet-dev-6-x86_64 --serverUrl=http://rhelsat/XMLRPC --sslCACert=/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT -v --force & wait $!
		else
		echo "Registering on RHELSAT using PROD activation key...please wait"
		rhnreg_ks --activationkey=11-puppet-prod-6-x86_64 --serverUrl=http://rhelsat/XMLRPC --sslCACert=/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT -v --force & wait $!
	fi # end 'Register on RHELSAT' if statement
		fi # end 'DEV system' if statement
		echo "Do you want to update the system? (y/n):    "
		read -r update
		if [ "$update" = y ]
			then
			echo ""
			echo ""
			echo "Setting up the Yum repos and updating the system...please wait..."
			echo "Cleaning up the repos..."
			echo ""
			echo ""
			yum clean all & wait $!
			echo ""
			echo ""
			echo "Updating the repolist..."
			echo ""
			echo ""
			yum repolist all & wait $!
			echo ""
			echo ""
			echo "running yum -y -q update...this may take a while...please wait..."
			echo ""
			echo ""
			yum -y -q update & wait $!
			echo ""
			echo ""
		fi # end 'YUM Update' if statement
		echo "Do you want to set the IO Scheduler to noop? (Recommended) (y/n):    "
		read -r noop
		if [ "$noop" = y ]
			then
			echo "Setting elevator=noop on the grub bootloader (/boot/grub/grub.conf)"
			sed '/kernel/ s/$/ elevator=noop/' -i /boot/grub/grub.conf & wait $!
		fi # end 'noop' if statement
		echo "Do you want to puppetise the VM? (y/n):    "	
		read -r puppet
		if [ "$puppet" = y ]
			then
			read -p "Hit any key once you have added the node to the Puppet Master to continue..." -n 1 -r
			echo "cleaning old puppet ssl cert"
			rm -rf /etc/puppet/ssl/* & wait $!
			echo "cleaning old puppet ssl cert...done"
			sleep 1
			echo "In the next step the puppet agent will require you to sign the puppet cert request on the puppet master"
			echo "The timeout is set to 1000 so you have plenty of time to sign it"
			sleep 2
			echo "Now running...puppet agent --server=puppet --ssldir=/etc/puppet/ssl -t -w 1000 --pluginsync --environment=prod"
			echo "WARNING: You need to sign the puppet cert request on the puppet server (sudo puppetca --sign $NAME) now"
			echo "WARNING: You need to sign the puppet cert request on the puppet server (sudo puppetca --sign $NAME) now"
			puppet agent --server=puppet --ssldir=/etc/puppet/ssl -t -w 1000 --pluginsync --environment=prod & wait $!
			echo "By now Puppet should have completed it's initial run..."
			echo "Puppet will have changed the root password by now"
			echo "See the rootPW set on the Puppet Server"
			sleep 8
		fi # end 'Puppet' if statement
		echo "First boot configuration complete..."
		echo "Do you want to reboot now? (y/n):    "
        read -r reboot
    	if [ "$reboot" = y ]
			then
			echo "Removing the script so that it won't execute again!"
			rm -f /root/lastrun
			mv -f /root/update.sh /tmp
			echo "If you want to re-run this script then do the following:"
			echo "		touch /root/firstrun"
			echo "		touch /root/lastrun"
			echo "		mv -f /tmp/update.sh /root/"
			echo "then reboot and this script will run again"
			echo "First boot configuration complete...rebooting...please wait"
			sleep 8
			init 6
		else
		echo "First boot configuration complete"
		echo "Removing the script so that it won't execute again!"
		rm -f /root/lastrun
		mv -f /root/update.sh /tmp
		echo "If you want to re-run this script then do the following:"
		echo "		touch /root/firstrun"
		echo "		touch /root/lastrun"
		echo "		mv -f /tmp/update.sh /root/"
		echo "then reboot and this script will run again"
		echo "VM ready for use"
		sleep 8
		fi # end 'reboot' if statement
fi # end for '/root/lastrun exists' if statement

