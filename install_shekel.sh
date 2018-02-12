#!/bin/bash
# Copyright Cryptojatt(c) 2018 
# https://github.com/cryptojatt
# install_shekel.sh version 1.5
# 
# Created for shekel.io
# See https://github.com/shekeltechnologies
# You may add, modify, remove and reuse anything below this notice

# Usage:
# su to root (sudo su -) if not already root
# wget https://raw.githubusercontent.com/cryptojatt/System-Administrator/master/install_shekel.sh
# chmod +x
# e.g. chmod +x install_shekel.sh
# then run ./install_shekel.sh

# Requirements
# Ubuntu 14.04 or Ubuntu 16.04
# Basic bash knowledge in executing shell scripts

# Create a function to configure the shekel.conf file through user input and then allow port 5500 through the UFW firewall
# The function will then start shekeld and attempt to tell you if your masternode has started
# depending on whether the blockchain has synced before the timer runs out.
configure () { 
	#echo "generating .shekel directory"
	#mkdir ~/.shekel & wait $!
	echo "generating ~/.shekel/shekel.conf" & wait $!
	echo -e rpcuser= >> ~/.shekel/shekel.conf & wait $!
	echo -e rpcpassword= >> ~/.shekel/shekel.conf & wait $!
	echo -e rpcport=5501 >> ~/.shekel/shekel.conf & wait $!
	echo -e listen=1 >> ~/.shekel/shekel.conf & wait $!
	echo -e server=1 >> ~/.shekel/shekel.conf & wait $!
	echo -e daemon=1 >> ~/.shekel/shekel.conf & wait $!
	echo -e maxconnections=256 >> ~/.shekel/shekel.conf & wait $!
	echo -e masternode=1 >> ~/.shekel/shekel.conf & wait $!
	echo -e externalip= >> ~/.shekel/shekel.conf & wait $!
	echo -e masternodeaddr= >> ~/.shekel/shekel.conf & wait $!
	echo -e masternodeprivkey= >> ~/.shekel/shekel.conf & wait $!
	sleep 2
	echo -n "enter the rpcuser:		:"
	read -r rpcuser
	echo -n "enter the rpcpassword		:"
	read -r rpcpassword
	echo -n "enter the externalip (IP ONLY, do not enter :5500 after the IP)	:"
	read -r externalip
	echo -n "enter the masternodeprivatekey		:"
	read -r masternodeprivkey
	echo "These were your answers		:"
	echo ""
	echo ""
	echo $rpcuser
	echo $rpcpassword
	echo $externalip
	echo $masternodeprivkey
	sleep 2
	echo "Using your answers to generate the shekel.conf"
	sed -i '/rpcuser/c\' ~/.shekel/shekel.conf
	echo "rpcuser=$rpcuser" >> ~/.shekel/shekel.conf
	sed -i '/rpcpassword/c\' ~/.shekel/shekel.conf
	echo "rpcpassword=$rpcpassword" >> ~/.shekel/shekel.conf
	sed -i '/externalip/c\' ~/.shekel/shekel.conf
	echo "externalip=$externalip:5500" >> ~/.shekel/shekel.conf
	sed -i '/masternodeaddr/c\' ~/.shekel/shekel.conf
	echo "masternodeaddr=$externalip:5500" >> ~/.shekel/shekel.conf
	sed -i '/masternodeprivkey/c\' ~/.shekel/shekel.conf
	echo "masternodeprivkey=$masternodeprivkey" >> ~/.shekel/shekel.conf
	sleep 2
	echo "done"
	echo "Checking firewall ports..."
	sleep 2
	PORTS='5500'
	STATUS='ufw status'
	for PORT in $PORTS; do
		echo $STATUS | grep "$PORT/tcp" > /dev/null
		if [ $? -gt 0 ]; then
			echo "Allowing SHEKEL port $PORT"
			echo "$PORT has been allowed"
			ufw allow $PORT/tcp > /dev/null
		fi
	done
	echo ""
	echo "UFW checked"
	sleep 2
	echo ""
	echo "starting shekeld..."
	shekeld
	echo "Waiting for shekeld to start and begin to sync..."
	sleep 2
	echo "While we're waiting for the chain to sync, continue with the following steps	:"
	sleep 2
	echo "Go to your cold wallet, open Tools > Debug console	"
	echo "enter 	masternode list-conf     into the console"
	echo ""
	sleep 10
	echo "You should see your masternode with a status of MISSING"
	echo ""
	sleep 5
	echo ""
	echo "Then back to the Debug console in your cold wallet"
	echo "enter		startmasternode alias false <YOUR_MN_ALIAS>"
	echo ""
	sleep 5
	echo -n "Hit enter once you have started the masternode	:"
	read -r enter
	echo ""
	echo "The script will now wait for the local wallet to sync with the chain...please wait"
	Getdiff=5
	IsShekelSynced() {
	Checkblockchain=`wget -O - http://shekelchain.com/api/getblockcount`
	Checkblockcount=`shekel-cli getblockcount`
	Getdiff=`expr $Checkblockchain - $Checkblockcount`
	current_date_time="`date "+%Y-%m-%d %H:%M:%S"`";
	sleep 30
	}
	while [[ $Getdiff -gt 1 ]]
	do
	IsShekelSynced 2>/dev/null
	echo ""
	echo $current_date_time;
	echo ""
	echo "Explorer Block is $Checkblockchain"
	echo "Shekel block is $Checkblockcount"
	echo "Difference is $Getdiff"
	echo "----------------------"
	done
	echo ""
	echo "Local wallet is now in sync"
	shekel-cli mnsync reset
	echo "I just ran 	shekel-cli mnsync reset..."
	sleep 2 
	echo "This should force the wallet to grab the latest list of current running masternodes"
	sleep 2
	echo "This usually gets your masternode started"
	echo "Waiting for mnsync to complete...please wait"
	sleep 30
	shekel-cli getinfo
	shekel-cli masternode status
	sleep 5
	echo "Hopefully by now you should see your masternode above" 
	sleep 2
	echo "if not check your cold wallet's status or try 'shekel-cli masternode status' again, or restart if you still can't see it"
	echo ""
	sleep 2
	cat ~/.shekel/debug.log | grep CActiveMasternode::EnableHotColdMasterNode
	sleep 2
	echo "You should see the enabled message above, if not you will need to troubleshoot further"
	sleep 5
	echo -n "Hit any key to continue	:"
	rear -r goodbye
	echo "Wallet configured any synced"
	echo "Masternode set up"
	echo "goodbye"
	sleep 3
} # end the configure function



clear # clear the screen
echo "###################################################"
echo "##           SHEKEL Wallet Installer             ##"
echo "##         For Ubuntu 14.04 or 16.04             ##"
echo "##                version 1.5                    ##"
echo "###################################################"
echo ""
echo ""
echo "You must run this script as root"
echo ""
echo "Please wait..."
sleep 5
if [[ `lsb_release -rs` == "14.04" ]] # This checks if lsb_release on the server reports Ubuntu 14.04, if not it skips this section
then
	echo "This is Ubuntu 14.04"	
echo "Are you upgrading? (y/n		:"	
read -r upgrade
	if [ "$upgrade" = n ]
		then
		echo "Installing Shekel on 14.04.from scratch"
		# Patches the system, installs required packages and repositories
		apt-get update &&
		apt-get upgrade -y &&
		apt-get install wget nano unrar unzip libboost-all-dev libevent-dev software-properties-common libzmq3 libminiupnpc-dev -qy
		if [ ! -e /etc/apt/sources.list.d/bitcoin-bitcoin-trusty.list ]
			then 
		    	add-apt-repository ppa:bitcoin/bitcoin -y
			apt-get update
		fi
		apt-get install libdb4.8-dev libdb4.8++-dev -qy &&
		# Downloads and extracts the current latest release, moves to the correct location then runs shekeld
		wget https://github.com/shekeltechnologies/JewNew/releases/download/1.3.0.0/shekel-linux-1.3.0.zip &&
		unzip shekel-linux-1.3.0.zip &&
		rm shekel-linux-1.3.0.zip &&
		chmod +x shekel-cli shekeld &&
		mv shekel-cli shekeld /usr/local/bin/
		echo "Shekel installed"
		sleep 2
		shekeld
		echo "Shekeld has been run once, it should have created the .shekel directory"
		sleep 2
	configure # calls to run the configure function defined right at the top of the script
	fi
	if [ "$upgrade" = y ]
	then
	echo "Upgrades not supported yet" # Will be supported in a later release
	fi # ends the upgrade check if-statement
fi # ends the 14.04 if-statement
if [[ `lsb_release -rs` == "16.04" ]] # This checks if lsb_release on the server reports Ubuntu 14.04, if not it skips this section
then
	echo "This is Ubuntu 16.04"
echo "Are you upgrading? (y/n)		:"	
read -r upgrade2
	if [ "$upgrade2" = n ]
		then
		echo "Installing Shekel on 16.04 from scratch"
		apt-get update &&
		apt-get upgrade -y &&
		apt-get install wget nano unrar unzip libboost-all-dev libevent-dev software-properties-common libzmq3-dev libminiupnpc-dev -qy
		if [ ! -e /etc/apt/sources.list.d/bitcoin-ubuntu-bitcoin-xenial.list ]
			then 
		    	add-apt-repository ppa:bitcoin/bitcoin -y &&
			apt-get update
		fi
		apt-get install libdb4.8-dev libdb4.8++-dev -qy &&
		wget https://github.com/shekeltechnologies/JewNew/releases/download/1.3.0.0/shekel-Ubuntu16.04-1.3.0.zip &&
		unzip shekel-Ubuntu16.04-1.3.0.zip &&
		rm shekel-Ubuntu16.04-1.3.0.zip &&
		chmod +x shekel-cli shekeld &&
		mv shekel-cli shekeld /usr/local/bin/
		echo "Shekel installed"
		sleep 2
		shekeld
		echo "Shekeld has been run once, it should have created the .shekel directory"
		sleep 2
	configure # calls to run the configure function defined right at the top of the script
	fi # ends the upgrade = n if-statement
	if [ "$upgrade" = y ]
	then
	echo "Upgrades not supported yet" # This will be added in a later version of this script
	fi # ends the upgrade = y if-statement
	
else # if the lsb_release check fails, proceed to the next portion of the script after this
	if [ `lsb_release -rs` != "14.04" ] && [ `lsb_release -rs` != "16.04" ]
	then
		echo "This is an unsupported OS" 
		# If the above two lsb_release checks fail, i.e the lsb_release file does not show a supported version of Ubuntu, or any other linux, it will not support it and halt the script from making any changes
	fi # end unsupported OS check	
fi # end the lsb_release check if-statement
