#!/bin/bash
# Copyright Cryptojatt(c) 2018 
# https://github.com/cryptojatt
# install_karmanode.sh version 1.0
# Bitcoin Donation address: 19rUHQQ2PNGzGzvLgoY9SiEwUCcNxJ2cqT
# Litecoin Donation address: LiBKYy6ZpCzTPpkqYaHPmjfuiQiLvxkNDE
# Shekel Donation address: JQJ1GanDU3c5RZwNjBXk68wFdxEJKLwWZU
#
# You may add, modify, remove and reuse anything below this notice
# please retain this notice and donation addresses
#
# Disclaimer
# By using this script, you accept:
# No warranty is implied nor given with this script
# you install, execute and/or modify this script at your own risk
# The author will not be held responsible for any consequence of this script

# Usage
# 1) su to root (sudo su -) if not already root
# or run with sudo
# 2) chmod +x install_ohm.sh
# 3) run ./install_ohm.sh
# or sudo ./install_ohm.sh

# Requirements
# Ubuntu 14.04 or Ubuntu 16.04 or CentOS7
# NOTE: Some projects may need the source code adapted to work if they fork off a different coin
# this won't work for all karmanodes out of the box.
# 

##### CHANGABLE VARIABLES #####
COIN="OHM"
datadir="ohmc"
daemon="ohmcd"
cli="ohmc-cli"
gitdir="ohmcoin"
GITREPO="https://github.com/theohmproject/ohmcoin.git"
getblockcount="`curl -s http://explore.ohmcoin.org/api/getblockcount`"
PORT="52020"
externalip="`curl -s http://whatismyip.akamai.com`"
##### CHANGABLE VARIABLES #####

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

######## ======== CONFIGURE FUNCTIONS ======== ########
start_daemon () {
if [ -f /etc/systemd/system/$COIN.service ];
then
	echo -e "$COIN Systemd service found!"
	if [ "systemctl status $COIN.service | grep running" ];
        then
                echo -e "${RED}$COIN service is running${NC}"	
	else
        	systemctl start $COIN.service
        	echo -e "${RED}Starting $COIN.service...${NC}"
        	sleep 5
	fi
        if [ "systemctl status $COIN.service | grep running" ];
	then
        	echo -e "${RED}$COIN service is running${NC}"
        else
        	echo -e "${RED}Error! $COIN is not running"
                echo -e "There may be a problem with the service"
                echo -e "You may need to quit the script and start the service manually!${NC}"
                sleep 5
        fi # end $COIN.service running
else	
	if pgrep -x $daemon > /dev/null
	then
		echo -e "${RED}$daemon is running${NC}"
	else
		echo -e "${RED}starting $daemon...${NC}"
		$daemon -daemon
	fi
fi
}

stop_daemon () {
if [ -f /etc/systemd/system/$COIN.service ];
then
        echo -e "${RED}$COIN Systemd service found!${NC}"
	if [ "systemctl status $COIN.service | grep running" ];
        then	
		systemctl stop $COIN.service
                echo -e "${RED}$COIN service is stopping${NC}"
		sleep 5
		$cli stop
        else
                echo -e "${RED}$COIN.service is not running${NC}"
                sleep 5
        fi
        if [ "systemctl status $COIN.service | grep running" ];
        then
                echo -e "${RED}Error! $COIN service is still running"
                echo -e "There may be a problem with the service"
                echo -e "You may need to quit the script and stop the service manually!${NC}"
                sleep 5
        fi # end $COIN.service running
else
        if pgrep -x $daemon > /dev/null
        then
        	echo -e "${RED}$daemon is stopping${NC}"
		$cli stop
        else
        	echo -e "${RED}$daemon still running"
		echo -e "There may be a problem with the service"
                echo -e "You may need to quit the script and stop the daemon manually!${NC}"
        fi
fi
}

configure () { 
clear
rpcuser="ohmrpc"
rpcpassword=`$daemon 2>&1 | grep '^rpcpassword='`
echo -e "${RED}$daemon has been run once, it should have created the .$datadir directory and generated the rpcpassword${NC}"
owner=$(chown $currentuser:$currentuser $homedir/.$datadir -R)
echo $owner
sleep 2
echo -e "${RED}Checking $homedir/.$datadir/$datadir.conf exists${NC}" & wait $!
if [ -f $homedir/.$datadir/$datadir.conf ]; then
        echo -e "${RED}$datadir.conf exists!"
        echo -e "Proceeding with configuring masternode...${NC}"
        sleep 2
	#rpcuser=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
	#rpcpassword=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
	echo "generating $homedir/.$datadir/$datadir.conf" & wait $!
	echo rpcuser=$rpcuser >> $homedir/.$datadir/$datadir.conf & wait $!
	echo $rpcpassword >> $homedir/.$datadir/$datadir.conf & wait $!
	echo rpcallowip=127.0.0.1 >> $homedir/.$datadir/$datadir.conf & wait $!
	#echo -e rpcport=$RPC_PORT >> ~/.$datadir/$datadir.conf & wait $!
	echo staking=1 >> $homedir/.$datadir/$datadir.conf & wait $!
	echo listen=1 >> $homedir/.$datadir/$datadir.conf & wait $!
	echo daemon=1 >> $homedir/.$datadir/$datadir.conf & wait $!
	echo logtimestamps=1 >> $homedir/.$datadir/$datadir.conf & wait $!
	echo maxconnections=256 >> $homedir/.$datadir/$datadir.conf & wait $!
	echo karmanode=1 >> $homedir/.$datadir/$datadir.conf & wait $!
	#echo -e -e externalip= >> ~/.$datadir/$datadir.conf & wait $!
	#echo -e -e karmanodeaddr= >> ~/.$datadir/$datadir.conf & wait $!
	echo karmanodeprivkey= >> $homedir/.$datadir/$datadir.conf & wait $!
	sleep 2
	echo -e "${RED}Your rpcuser is ${GREEN}$rpcuser"
	echo -e "${RED}Your rpcpassword is ${GREEN}$rpcpassword"
	echo -e "${RED}Make sure to save your rpc username and password for your cold wallet later"
	echo -e -n "Press enter key to continue${NC}"
	read -r cont
	echo -e ""
	echo -n "enter the karmanodeprivatekey		:"
	read -r karmanodeprivkey
	echo -e "These were your answers		:"
	echo -e ""
	echo -e ""
	echo -e "${GREEN}rpcuser=$rpcuser"
	echo -e $rpcpassword
	echo -e $externalip
	echo -e $karmanodeprivkey${NC}
	sleep 5
	echo -e "${RED}Using your answers to generate the .conf${NC}"
	#sed -i '/externalip/c\' $homedir/.$datadir/$datadir.conf
	#echo -e "externalip=$externalip:$PORT" >> $homedir/.$datadir/$datadir.conf
	#sed -i '/karmanodeaddr/c\' $homedir/.$datadir/$datadir.conf
	#echo -e "karmanodeaddr=$externalip:$PORT" >> $homedir/.$datadir/$datadir.conf
	sed -i '/karmanodeprivkey/c\' $homedir/.$datadir/$datadir.conf
	echo "karmanodeprivkey=$karmanodeprivkey" >> $homedir/.$datadir/$datadir.conf
	sleep 2
	echo -e "${RED}Configuration completed successfully${NC}"
	sleep 2
else
        echo -e "${RED}$datadir.conf not found"
	echo -e "This means the daemon install failed and the daemon didn't run properly"
	echo -e "Please re-run the script or check the git repo paths are correct"
	echo -e "Try installing the wallet from the git repo source manually to verify if the error is in this script or the source"
        echo -e -n "Hit enter key to continue        :"
        read -r goodbye
        echo -e ""
        echo -e "You will now be sent back to the menu"
        echo -e "goodbye"
        sleep 5
	echo -e "done${NC}"
fi
}	
	
check_ufw () {	
clear
echo -e "${RED}Checking firewall ports...${NC}"
sleep 2
#ufw status  | grep $PORT
if [ "ufw status | grep $PORT" ]; then
	echo -e "${RED}Port ${GREEN}$PORT${RED} already in UFW${NC}"
else
	echo -e "${RED}Adding port ${GREEN}$PORT${RED} to UFW rules - ${GREEN}ufw allow $PORT/tcp${NC}"
	ufw --force allow $PORT/tcp > /dev/null
	echo -e "${GREEN}$PORT${RED} has been allowed${NC}"
fi
echo -e "${RED}Checking SSH port in config...${NC}"
ssh="`grep -r Port /etc/ssh/sshd_config | awk '{print $2}'`"
echo -e "${RED}SSH port is port ${GREEN}$ssh...${NC}"
if [ "ufw status | grep $ssh" ]; then
	echo -e "${RED}Port ${GREEN}$ssh ${RED}already in UFW${NC}"
else
	echo -e "${RED}Adding ssh port to UFW rules - ${GREEN}ufw limit $ssh/tcp comment 'SSH port rate limit'${NC}"
	ufw --force limit $ssh/tcp comment 'SSH port rate limit' > /dev/null
fi
if [ "¬ufw satus | grep -qw active" ];
then
	echo -e "${RED}UFW is active${NC}"
else
	echo -e "${RED}UFW is inactive..."
	echo -e "Activating UFW${NC}"
	ufw --force enable
fi

echo -e ""
echo -e "${RED}UFW checked${NC}"
sleep 2
echo -e ""
}

start_karmanode () {
clear
	start_daemon
#ohmcd -daemon
	sleep 2
	echo -e "${RED}While waiting for the chain to sync, continue with the following steps	:"
	sleep 2
	echo -e "Go to your cold wallet, open Tools > Debug console	"
	echo -e "enter ${GREEN}karmanode list-conf ${RED}into the console"
	echo -e ""
	sleep 2
	echo -e "You should see your karmanode with a status of ${GREEN}MISSING${RED}"
	echo -e ""
	sleep 2
	echo -e ""
	echo -e "Then select the Karmanode tab, right-click your karmanode alias"
	echo -e "click ${GREEN}Start Alias${RED}"
	echo -e ""
	sleep 2
	echo -e -n "Hit enter once you have started the karmanode	:"
	read -r enter
	echo -e ""
	echo -e "The script will now wait for the local wallet to sync with the chain...please wait${NC}"
	Getdiff=5
	IsItSynced() {
	Checkblockchain=$getblockcount
	Checkblockcount=`$cli getblockcount`
	Getdiff=`expr $Checkblockchain - $Checkblockcount`
	current_date_time=`date "+%Y-%m-%d %H:%M:%S"`
	sleep 10
	}
	while [[ $Getdiff -gt 1 ]]
	do
	IsItSynced 2> /dev/null
	echo -e ""
	echo -e $current_date_time
	echo -e ""
	echo -e "${RED}Explorer Block is ${GREEN}$Checkblockchain"
	echo -e "${RED}Local Wallet Block is ${GREEN}$Checkblockcount"
	echo -e "${RED}Difference is ${GREEN}$Getdiff"
	echo -e "${RED}Waiting for wallet to match the Explorer block for it to be in sync"
	echo -e "Please wait...."
	echo -e "----------------------"
	done
	echo -e ""
	echo -e "Local wallet is now in sync${NC}"
	stop_daemon
	sleep 5
	echo -e "${RED}deleting mncache file...${NC}"
	rm $homedir/.$datadir/mncache.dat -rf
	sleep 2
	start_daemon
    	echo -e "${RED}Please wait 10 seconds"
	sleep 10
	echo -e "Running mnsync reset${NC}"
	$cli mnsync reset
	echo -e "${RED}This should force the wallet to grab the latest list of current running karmanodes"
	echo -e "Waiting for mnsync to complete...please wait${NC}"
	sleep 10
	$cli getinfo
	$cli karmanode status
	sleep 5
	echo -e "${RED}Hopefully by now you should see your karmanode above" 
	sleep 2
	echo -e "if not check your cold wallet's status or try ${GREEN}'$cli karmanode status' ${RED}again, or restart if you still can't see it${NC}"
	echo -e ""
	sleep 2
	cat $homedir/.$datadir/debug.log | grep CActiveKarmanode::EnableHotColdMasterNode
	sleep 2
	echo -e "${RED}You should see the enabled message above, if not you will need to troubleshoot further"
	sleep 5
	echo -e ""
	echo -e "If this helped you please consider donating here for my efforts	:${NC}"
	echo -e "Press enter key to continue"
	read -r goodbye
	echo -e ""
	echo -e "${RED}You will now be sent back to the menu"
	echo -e "Goodbye${NC}"
	sleep 3
} # end the start_karmanode function

upgrade () { 
clear
stop_daemon
echo -e "Checking $homedir/.$datadir/$datadir.conf exists" & wait $!
if [ -f $homedir/.$datadir/$datadir.conf ]; then
	echo -e "${RED}$datadir.conf exists!"
	echo -e "Proceeding with upgrade...${NC}"
	sleep 2
	clear
	if grep -q 14.04 /etc/*elease
	then
        	echo -e "${RED}This is Ubuntu 14.04"
        	echo -e "Installing ${GREEN}$COIN ${RED}on 14.04.from scratch${NC}"
        	libzmq="libzmq3"
        	run_apt
        	check_ufw
        	git_install
        	start_karmanode
	fi # ends the 14.04 if-statement
	if grep -q 16.04 /etc/*elease
	then
        	echo -e "${RED}This is Ubuntu 16.04"
        	echo -e "Installing ${GREEN}$COIN ${RED}on 16.04 from scratch${NC}"
        	libzmq="libzmq3-dev"
        	run_apt
        	check_ufw
        	git_install
        	start_karmanode
	fi # ends the 16.04 if-statement
	if grep -q centos /etc/*elease
	then
        	echo -e "${RED}This is CentOS"
        	echo -e "Installing ${GREEN}$COIN ${RED}on CentOS from scratch${NC}"
        	run_yum
        	check_iptables
        	git_install
        	start_karmanode
	fi
	if ! grep -q 14.04 /etc/*elease && ! grep -q 16.04 /etc/*elease && ! grep -q centos /etc/*elease;
	then
        	echo -e "${RED}This is an unsupported OS${NC}"
	fi # end unsupported OS check
else
	echo -e "$datadir.conf not found"
	echo -e "You either have a custom install in a custom location..."
	echo -e "...or you have not installed a karmanode yet..."
	echo -e -n "Hit enter key to continue	:"
	read -r goodbye
	echo -e ""
	echo -e "You will now be sent back to the menu"
	echo -e "goodbye"
	sleep 5
fi # end if $datadir.conf exists	
} # end the upgrade

check_iptables () { 
clear
	echo -e "${RED}Checking firewall ports...${NC}"
	sleep 2
	if [ "iptables -L INPUT -nv | grep -q $PORT" ]
	then 
		echo -e "${RED}Port ${GREEN}$PORT ${RED}already in iptables"
	else
		echo -e "${RED}Adding iptables rules - ${GREEN}iptables -I INPUT -p tcp --dport $PORT -j ACCEPT${NC}"
		iptables -I INPUT -p tcp --dport $PORT -j ACCEPT
		service iptables save
	fi
	echo -e "${RED}Checking SSH port in config...${NC}"
	ssh=`grep -r Port /etc/ssh/sshd_config | awk '{print $2}'`
	echo -e "${RED}SSH port is port ${GREEN}$ssh...${NC}"
	if [ "iptables -L INPUT -nv | grep -q $ssh" ]
	then
		echo -e "${RED}Port ${GREEN}$ssh ${RED}already in iptables"
	else
		echo -e "${RED}Adding ssh port to iptable rules - ${GREEN}iptables -I INPUT -p tcp --dport $ssh -j ACCEPT${NC}"
		iptables -I INPUT -p tcp --dport $ssh -j ACCEPT
		service iptables save
	fi
	echo -e ""
	echo -e "${RED}IPtables checked and saved${NC}"
	sleep 2
} # end the iptables function

######## ======== INSTALL FUNCTIONS ======== ########
git_install () {
clear
	# Downloads and extracts the current latest release, moves to the correct location then runs $daemon
	git clone $GITREPO
	cd $gitdir
	chmod +x share/genbuild.sh
	chmod +x autogen.sh
	chmod 755 src/leveldb/build_detect_platform
	./autogen.sh
	./configure --without-gui
	make
	if [ -f "/usr/local/bin/$daemon" ]; 
	then 
		echo -e "${RED}found existing ${GREEN}$daemon"
		echo -e "${RED}Deleting existing daemon${NC}"
		make uninstall
		if [ -f "/usr/local/bin/$daemon" ] || [ -f "/usr/local/bin/$cli" ];
		then
		rm /usr/local/bin/$daemon
		rm /usr/local/bin/$cli
		echo -e "${RED}$daemon and $cli manually deleted${NC}"
		fi
	fi
	make install
	echo -e "${RED}$COIN installed${NC}"
	sleep 2
	cd ..
	rm -rf $homedir/$gitdir
}

run_apt () {
clear
apt-get update &&
apt-get upgrade -y &&
apt-get install -yq \
	curl \
	pkg-config \
	build-essential \
	autoconf \
	automake \
	libtool \
	libboost-all-dev \
	libgmp-dev \
	libssl-dev \
	libcurl4-openssl-dev \
	git \
	libevent-dev \
	software-properties-common \
	$libzmq \
	libminiupnpc-dev &&
if [ ! -f "/etc/apt/sources.list.d/bitcoin-bitcoin-trusty.list" ] || [ ! -f "/etc/apt/sources.list.d/bitcoin-ubuntu-bitcoin-xenial.list" ]
then 
   	add-apt-repository ppa:bitcoin/bitcoin -y
	apt-get update
fi # ends ppa if-statement
apt-get install libdb4.8-dev libdb4.8++-dev -qy
}

run_yum () {
clear
yum install -y epel-release &&
yum clean all &&
yum repolist all &&
yum -y -q update &&
yum -y -q install \
	autoconf \
	automake \
	boost-devel \
	gcc-c++ \
	git \
	libdb4-cxx \
	libdb4-cxx-devel \
	libevent-devel \
	libtool \
    	openssl-devel \
    	wget \
	curl \
	miniupnpc-devel \
	zeromq
}

install () {
clear
if grep -q 14.04 /etc/*elease
then
	echo -e "${RED}This is Ubuntu 14.04"	
	echo -e "Installing ${GREEN}$COIN ${RED}on 14.04.from scratch${NC}"
	libzmq="libzmq3"
	run_apt
	check_ufw
	git_install
	configure
	start_karmanode
fi # ends the 14.04 if-statement
if grep -q 16.04 /etc/*elease
then
	echo -e "${RED}This is Ubuntu 16.04"
	echo -e "Installing ${GREEN}$COIN ${RED}on 16.04 from scratch${NC}"
	libzmq="libzmq3-dev"
	run_apt
	check_ufw
	git_install
	configure
	start_karmanode
fi # ends the 16.04 if-statement
if grep -q centos /etc/*elease
then
	echo -e "${RED}This is CentOS"
	echo -e "Installing ${GREEN}$COIN ${RED}on CentOS from scratch${NC}"
	run_yum
	check_iptables
	git_install
	configure
	start_karmanode
fi
if ! grep -q 14.04 /etc/*elease && ! grep -q 16.04 /etc/*elease && ! grep -q centos /etc/*elease;
then
	echo -e "${RED}This is an unsupported OS${NC}" 
fi # end unsupported OS check
} # end the karmanode_install function



######## ======== UPGRADE FUNCTIONS ======== ########
upgrade_karmanode () {
clear
	echo -e "${RED}This will upgrade your karmanode"
	echo -e "Replacing your existing ${GREEN}$daemon ${RED}and ${GREEN}$cli ${RED}with the latest available${NC}"
	sleep 5
if grep -q 14.04 /etc/*elease # This checks if the release file on the server reports Ubuntu 14.04, if not it skips this section
then
	echo -e "This is Ubuntu 14.04"	
		echo -e "Upgrading $COIN on 14.04"
		libzmq="libzmq3"
		echo -e "Patching system..."
		# Patches the system, installs required packages and repositories
		run_apt
		echo -e "Installed any missing packages"
		# Downloads and extracts the current latest release, moves to the correct location then runs $daemon
		git_install
		echo -e "Latest $daemon installed"
		sleep 2
		if [ -f /etc/systemd/system/$COIN.service ]; then
			echo -e "$COIN Systemd service found!"
			systemctl status $COIN.service
			echo -e "Current status of service above"
			sleep 5
			echo -e "Starting $COIN via systemd script"
			systemctl start $COIN.service
			sleep 5
		else
			echo -e "Starting $daemon..."
			$daemon -daemon
				sleep 2
		start_karmanode
		fi
fi # ends the 14.04 if-statement
if grep -q 16.04 /etc/*elease # This checks if any release file on the server reports Ubuntu 16.04, if not it skips this section
then
	echo -e "This is Ubuntu 16.04"
		echo -e "Installing $COIN on 16.04 from scratch"
		libzmq="libzmq3-dev"
		echo -e "Patching system..."
		# Patches the system, installs required packages and repositories
		run_apt
		echo -e "Installed any missing packages"
		# Downloads and extracts the current latest release, moves to the correct location then runs $daemon
		git_install
		echo -e "Latest $daemon installed"
		sleep 2
		if [ -f /etc/systemd/system/$COIN.service ]; then
			echo -e "$COIN Systemd service found!"
			systemctl status $COIN.service
			echo -e "Current status of service above"
			sleep 5
			echo -e "Starting $COIN via systemd script"
			systemctl start $COIN.service
			sleep 5
		else
			echo -e "Starting $daemon..."
			$daemon -daemon
				sleep 2
		start_karmanode
		fi
fi # ends the 16.04 if-statement
if grep -q centos /etc/*elease # This checks if any release file on the server reports Centos, if not it skips this section
then
	echo -e "This is CentOS"
		echo -e "Installing $COIN on CentOS from scratch"
		run_yum
		echo -e "Installed any missing packages"
		git_install
		echo -e "Latest $daemon installed"
		sleep 2
		if [ -f /etc/systemd/system/$COIN.service ]; then
			echo -e "$COIN Systemd service found!"
			systemctl status $COIN.service
			echo -e "Current status of service above"
			sleep 5
			echo -e "Starting $COIN via systemd script"
			systemctl start $COIN.service
			sleep 5
		else
			echo -e "Starting $daemon..."
			$daemon -daemon
				sleep 2
		start_karmanode
		fi
	if ! grep -q 14.04 /etc/*elease && ! grep -q 16.04 /etc/*elease && ! grep -q centos /etc/*elease;
	then
		echo -e "This is an unsupported OS" 
		# If the above two checks fail, i.e the lsb_release file does not show a supported version of Ubuntu, or any other linux, it will not support it and halt the script from making any changes
	fi # end unsupported OS check	
fi # end the centos check if-statement
}  # end the karmanode_upgrade function


install_service () {
clear
echo -e "Installing systemd script to start at boot and start $daemon...please wait"
sleep 5
cat <<EOF > /etc/systemd/system/$COIN.service
[Unit]
Description=$COIN's distributed currency daemon
After=network.target

[Service]
User=$currentuser


Type=forking
PIDFile=$homedir/.$datadir/$daemon.pid
ExecStart=/usr/local/bin/$daemon -daemon -pid=$homedir/.$datadir/$daemon.pid -conf=$homedir/.$datadir/$datadir.conf -datadir=$homedir/.$datadir
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
echo -e "script installed"
sleep 3
systemctl enable $COIN.service
echo -e "Script enabled"
sleep 3
stop_daemon
start_daemon
}

install_check () {
echo -e "Creating check.sh in $currentuser's home directory"
echo -e -n "Please paste your wallet address holding your $COIN collateral	:"
read -r add
echo -e "Enter your email address if you want notifications	:"
echo -e "You will need sendmail installed and configured"
read -r email
touch $homedir/check.sh
cat <<EOF  > $homedir/check.sh
#!/bin/bash

ipaddr=`curl -s http://whatismyip.akamai.com`
echo -e "Your External IP Address is..."
echo -e $externalip

abort()
{
    echo -e >&2 '
========================================
=== $daemon not running...restarting ===
========================================
'
rm $homedir/.$datadir/mncache.dat -rf
systemctl start $COIN.service
sleep 30
echo -e ""
echo -e ""
echo -e "==== getinfo OUTPUT ===="
   $cli getinfo
echo -e "==== getinfo OUTPUT ===="
echo -e ""
echo -e ""
  sleep 30
echo -e "==== karmanode status OUTPUT ===="
$cli karmanode status
echo -e "==== karmanode status OUTPUT ===="
echo -e ""
echo -e ""
echo -e "==== karmanode list OUTPUT ===="
$cli karmanode list $add
echo -e "==== karmanode list OUTPUT ===="
echo -e ""
echo -e ""
echo -e "==== debug.log OUTPUT ===="
cat $homedir/.$datadir/debug.log | grep CActiveKarmanode::EnableHotColdMasternode
echo -e "==== debug.log OUTPUT ===="
echo -e ""
echo -e ""
echo -e "You should see the following message above	:	"
echo -e "Enabled! You may shut down the cold daemon."
echo -e ""
echo -e "This means the karmanode is Enabled"
echo -e ""
echo -e ""
}

trap 'abort' 0

set -e

running=`$cli getinfo | grep version`
if [[ $running == *"version"* ]]; then
   echo -e "$COIN RUNNING!"
   echo -e "============"
echo -e ""
echo -e ""
echo -e "==== getinfo OUTPUT ===="
   $cli getinfo
echo -e "==== getinfo OUTPUT ===="
echo -e ""
echo -e ""
  sleep 30
echo -e "==== karmanode status OUTPUT ===="
  $cli karmanode status
echo -e "==== karmanode status OUTPUT ===="
echo -e ""
echo -e ""
echo -e "==== karmanode list OUTPUT ===="
  $cli karmanode list $add
echo -e "==== karmanode list OUTPUT ===="
echo -e ""
echo -e ""
echo -e "==== debug.log OUTPUT ===="
  cat $homedir/.$datadir/debug.log | grep CActiveKarmanode::EnableHotColdMasternode
echo -e "==== debug.log OUTPUT ===="
echo -e ""
echo -e ""
echo -e "You should see the following message above	:	"
echo -e "Enabled! You may shut down the cold daemon."
echo -e ""
echo -e "This means the karmanode is Enabled"
echo -e ""
echo -e ""
fi

check=`$cli karmanode list $add | grep ENABLED`
echo -e $check
if [[ $check == *"POS_ERROR"* ]]; then
   echo -e "POS ERROR!"
   systemctl stop $COIN
   sleep 30
   rm $homedir/.$datadir/mncache.dat -rf
   systemctl start $COIN
   sleep 30
echo -e ""
echo -e ""
echo -e "==== getinfo OUTPUT ===="
   $cli getinfo
echo -e "==== getinfo OUTPUT ===="
echo -e ""
echo -e ""
  sleep 30
echo -e "==== karmanode status OUTPUT ===="
$cli karmanode status
echo -e "==== karmanode status OUTPUT ===="
echo -e ""
echo -e ""
echo -e "==== karmanode list OUTPUT ===="
$cli karmanode list $add
echo -e "==== karmanode list OUTPUT ===="
echo -e ""
echo -e ""
echo -e "==== debug.log OUTPUT ===="
cat $homedir/.$datadir/debug.log | grep CActiveKarmanode::EnableHotColdMasternode
echo -e "==== debug.log OUTPUT ===="
echo -e ""
echo -e ""
echo -e "You should see the following message above	:	"
echo -e "Enabled! You may shut down the cold daemon."
echo -e ""
echo -e "This means the karmanode is Enabled"
echo -e ""
echo -e ""

echo -e $check

fi
if [[ $check == *"ENABLED"* ]]; then
   echo -e "$COIN ENABLED!"
echo -e ""
echo -e ""
echo -e "==== getinfo OUTPUT ===="
   $cli getinfo
echo -e "==== getinfo OUTPUT ===="
echo -e ""
echo -e ""
  sleep 30
echo -e "==== karmanode status OUTPUT ===="
$cli karmanode status
echo -e "==== karmanode status OUTPUT ===="
echo -e ""
echo -e ""
echo -e "==== karmanode list OUTPUT ===="
$cli karmanode list $add
echo -e "==== karmanode list OUTPUT ===="
echo -e ""
echo -e ""
echo -e "==== debug.log OUTPUT ===="
cat $homedir/.$datadir/debug.log | grep CActiveKarmanode::EnableHotColdMasternode
echo -e "==== debug.log OUTPUT ===="
echo -e ""
echo -e ""
echo -e "You should see the following message above	:	"
echo -e "Enabled! You may shut down the cold daemon."
echo -e ""
echo -e "This means the karmanode is Enabled"
echo -e ""
echo -e ""

fi

trap : 0

EOF

if [ "$email" != "" ]
then
	chmod +x ~/check.sh
	sudo -u $currentuser crontab -l > mycron
	echo -e "*/30 * * * * $homedir/check.sh 2>&1 | tee output.txt | mail -s '$datadir karmanode status' $email"
	sudo -u $currentuser echo -e -e "*/30 * * * * $homedir/check.sh 2>&1 | tee output.txt | mail -s '$datadir karmanode status' $email" >> mycron
	sudo -u $currentuser crontab mycron
	sudo -u $currentuser rm mycron
else
	chmod +x $homedir/check.sh
	sudo -u $currentuser crontab -l > mycron
	echo -e "*/30 * * * * $homedir/check.sh"
	sudo -u $currentuser echo -e -e "*/30 * * * * $homedir/check.sh" >> mycron
	sudo -u $currentuser crontab mycron
	sudo -u $currentuser rm mycron
fi
}

amiroot () {
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root"
   echo -e "Run this script again as root or sudo"
   echo -e "e.g sudo ./install_ohm.sh"
   echo -e "this script will now exit${NC}"
   exit 1
fi
currentuser=$(logname)
if [ "$currentuser" == "root" ];
then
	homedir="/root"
else
	homedir="/home/$currentuser"
fi
}
################ ================ MENU ================ ################
menu () {
while :
do
    clear
echo -e "${RED}===================================================="
echo -e "==          Karmanode Wallet Installer            =="
echo -e "==      For Ubuntu 14.04 or 16.04 or CentOS7      =="
echo -e "==                  version 2.0                   =="
echo -e "==                                                =="
echo -e "== Please donate:                                 =="
echo -e "== Bitcoin:  19rUHQQ2PNGzGzvLgoY9SiEwUCcNxJ2cqT   =="
echo -e "== Litecoin: LiBKYy6ZpCzTPpkqYaHPmjfuiQiLvxkNDE   =="
echo -e "== Shekel:   JQJ1GanDU3c5RZwNjBXk68wFdxEJKLwWZU   =="
echo -e "== Ohm:      ZFjLmdQittBwSmJMCAHQkQfbuNV4Gs2vUu   =="
echo -e "==                                                =="
echo -e "==         Copyright Cryptojatt(c) 2018           ==" 
echo -e "==         https://github.com/cryptojatt          =="
echo -e "----------------------------------------------------"
echo -e "${NC}"
echo -e "Please consider donating for my time and effort I put into this	:" 
echo -e ""
sleep 1
cat <<EOF
$(echo -e    "${RED}    Please enter your choice:")

$(echo -e    "${GREEN}    Install Wallet & Set Up karmanode  (1)")
    Upgrade Wallet & Start karmanode   (2)
    Start karmanode                    (3)
    Install Systemd Service	       (4)
    Install check script	       (5)
           			       (Q)uit
$(echo -e    "${NC}    ------------------------------")
EOF
    read -n1 -s
    case "$REPLY" in
    "1")  install ;;
    "2")  upgrade ;;
    "3")  start_karmanode ;;
    "4")  install_service ;;
    "5")  install_check ;;
    "Q")  exit                      ;;
    "q")  echo -e "case sensitive!!"   ;; 
     * )  echo -e "invalid option"     ;;
    esac
    sleep 1
done
} # end menu while loop
amiroot
menu #start menu function
