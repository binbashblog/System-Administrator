#!/bin/bash

# Usage: 
# chmod +x and chown root
# su to root (sudo su -)
# copy to /root
# then run ./shekel.sh

configure () {
	echo "generating ~/.shekel/shekel.conf"
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
	sleep 1
	echo -n "enter the rpcuser:		:"
	read -r rpcuser
	echo -n "enter the rpcpassword		:"
	read -r rpcpassword
	echo -n "enter the externalip		:"
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
	ed -i '/masternodeaddr/c\' ~/.shekel/shekel.conf
	echo "masternodeaddr=$externalip:5500" >> ~/.shekel/shekel.conf
	sed -i '/masternodeprivkey/c\' ~/.shekel/shekel.conf
	echo "masternodeprivkey=$masternodeprivkey" >> ~/.shekel/shekel.conf
	sleep 1
	echo "done"
	echo "Checking firewall ports..."
	sleep 1
	PORTS='5500'
	STATUS='ufw status'
	for PORT in $PORTS; do
		echo $STATUS | grep "$PORT/tcp" > /dev/null
		if [ $? -gt 0 ]; then
			echo "Allowing SHEKEL port $PORT"
			ufw allow $PORT/tcp > /dev/null
		fi
	done
	echo ""
	echo "UFW checked"
	sleep 1
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
	sleep 5
	echo "You should see your masternode with a status of MISSING"
	echo ""
	sleep 5
	echo ""
	echo "Then back to the Debug console in your cold wallet"
	echo "enter		startmasternode alias false <YOUR_MN_ALIAS>"
	echo ""
	echo -n "Hit enter once you have started the masternode"
	echo "Waiting a minute for shekeld to sync...please wait"
	sleep 60
	shekel-cli mnsync reset
	echo "I just ran 	shekel-cli mnsync reset..."
	sleep 1 
	echo "This should force the wallet to grab the latest list of current running masternodes"
	sleep 1
	echo "This usually gets your masternode started"
	sleep 1
	shekel-cli getinfo
	shekel-cli masternode status
	sleep 5
	echo "Hopefully by now you should see your masternode above" 
	sleep 1
	echo "if not check your cold wallet's status or try 'shekel-cli masternode status' again, or restart if you still can't see it"
	echo ""
	sleep 1
	cat ~/.shekel/debug.log | grep CActiveMasternode::EnableHotColdMasterNode
	sleep 1
	echo "You should see the enabled message above, if not you will need to troubleshoot further"
	sleep 5
	echo "goodbye"
}



clear
echo "###################################################"
echo "##           SHEKEL Wallet Installer             ##"
echo "##         For Ubuntu 14.04 or 16.04             ##"
echo "##                 version 1                     ##"
echo "###################################################"
echo ""
echo ""
echo "You must run this script as root"
echo ""
echo "Please wait..."
sleep 5
if [[ `lsb_release -rs` == "14.04" ]] # replace 14.04 by the number of release you want
then
	echo "This is Ubuntu 14.04"	
echo "Are you upgrading? (y/n		:"	
read -r upgrade
	if [ "$upgrade" = n ]
		then
		echo "Installing Shekel on 14.04.from scratch"
		apt-get update &&
		apt-get upgrade -y &&
		apt-get install wget nano unrar unzip libboost-all-dev libevent-dev software-properties-common libzmq3 libminiupnpc-dev -qy
		if [ ! grep -q "^deb" /etc/apt/sources.list.d/* 2>/dev/null | grep -q bitcoin/bitcoin 2>/dev/null ]
			then 
		    add-apt-repository ppa:bitcoin/bitcoin -y &&
			apt-get update
		fi
		apt-get install libdb4.8-dev libdb4.8++-dev -qy &&
		wget https://github.com/shekeltechnologies/JewNew/releases/download/1.3.0.0/shekel-linux-1.3.0.zip &&
		unzip shekel-linux-1.3.0.zip &&
		rm shekel-linux-1.3.0.zip &&
		chmod +x shekel-cli shekeld &&
		mv shekel-cli shekeld /usr/local/bin/
		echo "Shekel installed"
		sleep 1
		shekeld
		echo "Shekeld has been run once, it should have created the .shekel directory"
		sleep 1
		configure
	fi
	if [ "$upgrade" = y ]
	then
	echo "Upgrades not supported yet"
	fi
fi
if [[ `lsb_release -rs` == "16.04" ]] # replace 16.04 by the number of release you want
then
	echo "This is Ubuntu 16.04"
echo "Are you upgrading? (y/n)		:"	
read -r upgrade
	if [ "$upgrade" = n ]
		then
		echo "Installing Shekel on 16.04 from scratch"
		apt-get update &&
		apt-get upgrade -y &&
		apt-get install wget nano unrar unzip libboost-all-dev libevent-dev software-properties-common libzmq3-dev libminiupnpc-dev -qy
		if [ ! grep -q "^deb" /etc/apt/sources.list.d/* 2>/dev/null | grep -q bitcoin/bitcoin 2>/dev/null ]
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
		sleep 1
		shekeld
		echo "Shekeld has been run once, it should have created the .shekel directory"
		sleep 1
	configure
	fi
	if [ "$upgrade" = y ]
	then
	echo "Upgrades not supported yet"
	fi
	
else
		echo "This is an unsupported OS"
fi
