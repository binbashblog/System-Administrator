#!/bin/bash
# Copyright Cryptojatt(c) 2018 
# https://github.com/cryptojatt
# install_shekel.sh version 2.0
# Donation address: JQJ1GanDU3c5RZwNjBXk68wFdxEJKLwWZU
# 
# Created for shekel.io
# See https://github.com/shekeltechnologies
# You may add, modify, remove and reuse anything below this notice
# please retain this notice and donation address

# Usage:
#
# su to root (sudo su -) if not already root
# or run with sudo
# wget https://raw.githubusercontent.com/cryptojatt/System-Administrator/master/install_shekel.sh
# chmod +x install_shekel.sh
# then run ./install_shekel.sh
# or sudo ./install_shekel.sh

# Requirements
# Ubuntu 14.04 or Ubuntu 16.04 or CentOS7
# Basic bash knowledge in executing shell scripts

# Create a function to configure the shekel.conf file through user input and then allow port 5500 through the firewall
# The function will then start shekeld, check the block explorer against the wallets sync progress until it is it sync
# and attempt to start up your masternode, and then verify if your masternode has started

configure_ubuntu () { 
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
	externalip=`curl -s http://whatismyip.akamai.com`
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
	echo "Checking SSH port in config..."
	ssh=`grep -r Port /etc/ssh/sshd_config | awk '{print $2}'`
	echo "SSH port is port $ssh..."
	
	if [ "ufw status | grep -q $ssh/tcp" ]; then
		echo "Port $ssh already in UFW"
	else
		echo "Adding ssh port to UFW rules - ufw allow $ssh/tcp"
		ufw allow $ssh/tcp > /dev/null
	fi
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
	echo "Local Wallet Block is $Checkblockcount"
	echo "Difference is $Getdiff"
	echo "Waiting for wallet to match the Explorer block for it to be in sync"
	echo "Please wait...."
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
	echo ""
	echo "If this helped you please consider donating here for my efforts	:"
	echo "JQJ1GanDU3c5RZwNjBXk68wFdxEJKLwWZU"
	echo ""
	echo -n "Hit any key to continue	:"
	read -r goodbye
	echo ""
	echo "goodbye"
	sleep 3
} # end the configure function

configure_centos () { 
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
	externalip=`curl -s http://whatismyip.akamai.com`
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
	if [ "iptables -L INPUT -nv | grep -q 5500" ]
	then 
		echo "Port 5500 already in iptables"
	else
		echo "Adding iptables rules - iptables -I INPUT -p tcp --dport 5500 -j ACCEPT"
		iptables -I INPUT -p tcp --dport 5500 -j ACCEPT
	service iptables save
	fi
	echo "Checking SSH port in config..."
	ssh=`grep -r Port /etc/ssh/sshd_config | awk '{print $2}'`
	echo "SSH port is port $ssh..."
	if [ "iptables -L INPUT -nv | grep -q $ssh" ]
	then
		etho "Port $ssh already in iptables"
	else
		echo "Adding ssh port to iptable rules - iptables -I INPUT -p tcp --dport $ssh -j ACCEPT"
		iptables -I INPUT -p tcp --dport $ssh -j ACCEPT
	service iptables save
	fi
	echo ""
	echo "IPtables checked and saved"
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
	echo "Local Wallet Block is $Checkblockcount"
	echo "Difference is $Getdiff"
	echo "Waiting for wallet to match the Explorer block for it to be in sync"
	echo "Please wait...."
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
	echo "Wallet configured and synced"
	echo "Masternode has been set up"
	echo ""
	echo "If this helped you please consider donating here for my efforts	:"
	echo "JQJ1GanDU3c5RZwNjBXk68wFdxEJKLwWZU"
	echo ""
	echo -n "Hit any key to continue	:"
	read -r goodbye
	echo ""
	echo "goodbye"
	sleep 3
} # end the configure function

install_masternode () {
if grep -q 14.04 /etc/*elease # This checks if lsb_release on the server reports Ubuntu 14.04, if not it skips this section
then
	echo "This is Ubuntu 14.04"	
		echo "Installing Shekel on 14.04.from scratch"
		# Patches the system, installs required packages and repositories
		apt-get update &&
		apt-get upgrade -y &&
		apt-get install wget curl nano unrar unzip libboost-all-dev libevent-dev software-properties-common libzmq3 libminiupnpc-dev -qy
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
	configure_ubuntu # calls to run the configure function defined right at the top of the script
fi # ends the 14.04 if-statement
if grep -q 16.04 /etc/*elease # This checks if lsb_release on the server reports Ubuntu 14.04, if not it skips this section
then
	echo "This is Ubuntu 16.04"
		echo "Installing Shekel on 16.04 from scratch"
		apt-get update &&
		apt-get upgrade -y &&
		apt-get install wget curl nano unrar unzip libboost-all-dev libevent-dev software-properties-common libzmq3-dev libminiupnpc-dev -qy
		if [ ! -e /etc/apt/sources.list.d/bitcoin-ubuntu-bitcoin-xenial.list ]
			then 
		    	add-apt-repository ppa:bitcoin/bitcoin -y &&
			apt-get update
		fi # ends ppa if-statement
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
	configure_ubuntu # calls to run the configure function defined right at the top of the script
		
fi # ends the 16.04 if-statement
if [ grep -q centos /etc/*elease ]
then
	echo "This is centos"
		echo "Installing Shekel on CentOS from scratch"
		yum install -y epel-release &&
		yum clean all &&
		yum repolist all &&
		yum -y -q update &&
		yum -y -q install unzip wget curl miniupnpc-devel zeromq libdb4-cxx
		wget https://github.com/cryptojatt/JewNew/files/1716935/shekel-CentOS7-1.3.0.zip
		unzip shekel-Ubuntu16.04-1.3.0.zip &&
		rm shekel-Ubuntu16.04-1.3.0.zip &&
		chmod +x shekel-cli shekeld &&
		mv shekel-cli shekeld /usr/local/bin/
		echo "Shekel installed"
		sleep 2
		shekeld
		echo "Shekeld has been run once, it should have created the .shekel directory"
		sleep 2
	configure_centos # calls to run the configure function defined right at the top of the script
	#		
	if ! grep -q 14.04 /etc/*elease && ! grep -q 16.04 /etc/*elease && ! grep -q centos /etc/*elease;
	then
		echo "This is an unsupported OS" 
		# If the above two checks fail, i.e the lsb_release file does not show a supported version of Ubuntu, or any other linux, it will not support it and halt the script from making any changes
	fi # end unsupported OS check	
fi # end the centos check if-statement
} # end the masternode_install function

upgrade_masternode () {
	echo "Upgrades not supported yet" # This will be added in a later version of this script
}

install_service () {
echo "Installing systemd script to start at boot and start shekeld...please wait"
sleep 5
cat <<EOF > /etc/systemd/system/shekel.service
[Unit]
Description=Shekel's distributed currency daemon
After=network.target

[Service]
User=$USER


Type=forking
PIDFile=~/.shekel/shekeld.pid
ExecStart=/usr/local/bin/shekeld -daemon -pid=~/.shekel/shekeld.pid -conf=~/.shekel/shekel.conf -datadir=~/.shekel
#-disablewallet

Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=2s
StartLimitInterval=120s
StartLimitBurst=5

[Install]
WantedBy=multi-user.target
EOF

echo "script installed"
sleep 3
systemctl enable shekel.service
echo "Script enabled"
sleep 3
echo "Checking if shekeld is running..."
SERVICE="shekeld"
RESULT=`ps -a | sed -n /${SERVICE}/p`
if [ "${RESULT:-null}" = null ]; then
    echo "Shekel is not running"
else
    echo "Stopping shekeld"
    shekel-cli stop
    sleep 3
    RESULT2=`ps -a | sed -n /${SERVICE}/p`
    if [ "${RESULT:-null}" = null ]; then
    	echo "Shekel is not running"
    else
        echo "Stopping shekeld"
	killall -9 shekeld
    fi
    
fi
echo "Starting the shekel.service service"
echo "Please wait 30 seconds"
systemctl start shekel.service
sleep 30
echo "Service should have started which you can see below"
echo ""
systemctl status shekel.service
sleep 3
echo "The service should show green above"
echo ""
sleep 3
echo "Status of shekel-cli getinfo..."
sleep 1
shekel-cli getinfo
sleep 1
echo "Status of masternode status"
shekel-cli masternode status
sleep 3
echo "done"
echo ""
echo "Going back to main menu"
sleep 3
}

install_check () {
echo "Creating check.sh in $USER's home directory"
echo -n "Please paste your wallet address holding your 25000 shekel collateral	:"
read -r add
echo "Enter your email address if you want notifications	:"
echo "You will need sendmail installed and configured"
read -r email
touch ~/check.sh
cat <<EOF  > ~/check.sh
#!/bin/bash

ipaddr=`curl -s http://whatismyip.akamai.com`
echo "Your External IP Address is..."
echo $ipaddr

abort()
{
    echo >&2 '
========================================
=== Shekeld not running...restarting ===
========================================
'
rm ~/.shekel/mncache.dat -rf
systemctl start shekeld
sleep 30
echo ""
echo ""
echo "==== getinfo OUTPUT ===="
   shekel-cli getinfo
echo "==== getinfo OUTPUT ===="
echo ""
echo ""
  sleep 30
echo "==== masternode status OUTPUT ===="
shekel-cli masternode status
echo "==== masternode status OUTPUT ===="
echo ""
echo ""
echo "==== masternode list OUTPUT ===="
shekel-cli masternode list $add
echo "==== masternode list OUTPUT ===="
echo ""
echo ""
echo "==== debug.log OUTPUT ===="
cat ~/.shekel/debug.log | grep CActiveMasternode::EnableHotColdMasterNode
echo "==== debug.log OUTPUT ===="
echo ""
echo ""
echo "You should see the following message above	:	"
echo "Enabled! You may shut down the cold daemon."
echo ""
echo "This means the masternode is Enabled"
echo ""
echo ""
}

trap 'abort' 0

set -e

running=`shekel-cli getinfo | grep version`
if [[ $running == *"version"* ]]; then
   echo "JEW RUNNING!"
   echo "============"
echo ""
echo ""
echo "==== getinfo OUTPUT ===="
   shekel-cli getinfo
echo "==== getinfo OUTPUT ===="
echo ""
echo ""
  sleep 30
echo "==== masternode status OUTPUT ===="
shekel-cli masternode status
echo "==== masternode status OUTPUT ===="
echo ""
echo ""
echo "==== masternode list OUTPUT ===="
shekel-cli masternode list $add
echo "==== masternode list OUTPUT ===="
echo ""
echo ""
echo "==== debug.log OUTPUT ===="
cat ~/.shekel/debug.log | grep CActiveMasternode::EnableHotColdMasterNode
echo "==== debug.log OUTPUT ===="
echo ""
echo ""
echo "You should see the following message above	:	"
echo "Enabled! You may shut down the cold daemon."
echo ""
echo "This means the masternode is Enabled"
echo ""
echo ""
fi

check=`shekel-cli masternode list $add | grep ENABLED`
echo $check
if [[ $check == *"POS_ERROR"* ]]; then
   echo "POS ERROR!"
   systemctl stop shekeld
   sleep 30
   rm ~/.shekel/mncache.dat -rf
   systemctl start shekel
   sleep 30
echo ""
echo ""
echo "==== getinfo OUTPUT ===="
   shekel-cli getinfo
echo "==== getinfo OUTPUT ===="
echo ""
echo ""
  sleep 30
echo "==== masternode status OUTPUT ===="
shekel-cli masternode status
echo "==== masternode status OUTPUT ===="
echo ""
echo ""
echo "==== masternode list OUTPUT ===="
shekel-cli masternode list $add
echo "==== masternode list OUTPUT ===="
echo ""
echo ""
echo "==== debug.log OUTPUT ===="
cat ~/.shekel/debug.log | grep CActiveMasternode::EnableHotColdMasterNode
echo "==== debug.log OUTPUT ===="
echo ""
echo ""
echo "You should see the following message above	:	"
echo "Enabled! You may shut down the cold daemon."
echo ""
echo "This means the masternode is Enabled"
echo ""
echo ""

echo $check

fi
if [[ $check == *"ENABLED"* ]]; then
   echo "JEW ENABLED!"
echo ""
echo ""
echo "==== getinfo OUTPUT ===="
   shekel-cli getinfo
echo "==== getinfo OUTPUT ===="
echo ""
echo ""
  sleep 30
echo "==== masternode status OUTPUT ===="
shekel-cli masternode status
echo "==== masternode status OUTPUT ===="
echo ""
echo ""
echo "==== masternode list OUTPUT ===="
shekel-cli masternode list $add
echo "==== masternode list OUTPUT ===="
echo ""
echo ""
echo "==== debug.log OUTPUT ===="
cat ~/.shekel/debug.log | grep CActiveMasternode::EnableHotColdMasterNode
echo "==== debug.log OUTPUT ===="
echo ""
echo ""
echo "You should see the following message above	:	"
echo "Enabled! You may shut down the cold daemon."
echo ""
echo "This means the masternode is Enabled"
echo ""
echo ""

fi

trap : 0

EOF

if [ "$email" != "" ]
then
	chmod +x ~/check.sh
	sudo -u $USER crontab -l > mycron
	echo "*/30 * * * * ~/check.sh 2>&1 | tee output.txt | mail -s 'Shekel Masternode status' $email"
	sudo -u $USER echo -e "*/30 * * * * ~/check.sh 2>&1 | tee output.txt | mail -s 'Shekel Masternode status' $email" >> mycron
	sudo -u $USER crontab mycron
	sudo -u $USER rm mycron
else
	chmod +x ~/check.sh
	sudo -u $USER crontab -l > mycron
	echo "*/30 * * * * ~/check.sh"
	sudo -u $USER echo -e "*/30 * * * * ~/check.sh" >> mycron
	sudo -u $USER crontab mycron
	sudo -u $USER rm mycron
fi
}

amiroot () {
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   echo "Run this script again as root or sudo"
   echo "e.g sudo ./install_shekel.sh"
   echo "this script will now exit"
   exit 1
fi
}

menu () {
while :
do
    clear
echo "==================================================="
echo "==           SHEKEL Wallet Installer             =="
echo "==     For Ubuntu 14.04 or 16.04 or CentOS7      =="
echo "==                version 2.0                    =="
echo "==   Donate:JQJ1GanDU3c5RZwNjBXk68wFdxEJKLwWZU   =="
echo "==                                               =="
echo "==         Copyright Cryptojatt(c) 2018          ==" 
echo "==        https://github.com/cryptojatt          =="
echo "==            Created for shekel.io              =="
echo "==   See https://github.com/shekeltechnologies   =="
echo "---------------------------------------------------"
echo ""
echo "Please consider donating here for my efforts	:" 
echo "JQJ1GanDU3c5RZwNjBXk68wFdxEJKLwWZU"
echo ""
sleep 2
amiroot
cat <<EOF
    Please enter your choice:

    Install Shekel Wallet & Set Up Masternode (1)
    Upgrade Shekel Wallet & Set Up Masternode (2)
    Install Systemd Service		      (3)
    Install Shekel check		      (4)
           				      (Q)uit
    ------------------------------
EOF
    read -n1 -s
    case "$REPLY" in
    "1")  install_masternode ;;
    "2")  upgrade_masternode ;;
    "3")  install_service ;;
    "4")  install_check ;;
    "Q")  exit                      ;;
    "q")  echo "case sensitive!!"   ;; 
     * )  echo "invalid option"     ;;
    esac
    sleep 1
done
} # end menu while loop

menu #start menu function
