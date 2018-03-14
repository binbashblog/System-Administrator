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
getblockcount="http://explore.ohmcoin.org/api/getblockcount"
PORT="52020"
externalip="curl -s http://whatismyip.akamai.com"
##### CHANGABLE VARIABLES #####

######## ======== CONFIGURE FUNCTIONS ======== ########
configure () { 
clear
echo "Checking ~/.$datadir/$datadir.conf exists" & wait $!
if [ -f ~/.$datadir/$datadir.conf ]; then
        echo "$datadir.conf exists!"
        echo "Proceeding with configuring masternode..."
        sleep 2
rpcuser=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
rpcpassword=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
	echo "generating ~/.$datadir/$datadir.conf" & wait $!
	echo -e rpcuser=$rpcuser >> ~/.$datadir/$datadir.conf & wait $!
	echo -e rpcpassword=$rpcpassword >> ~/.$datadir/$datadir.conf & wait $!
	echo -e rpcallowip=127.0.0.1 >> ~/.$datadir/$datadir.conf & wait $!
	#echo -e rpcport=$RPC_PORT >> ~/.$datadir/$datadir.conf & wait $!
	echo -e staking=1 >> ~/.$datadir/$datadir.conf & wait $!
	echo -e listen=1 >> ~/.$datadir/$datadir.conf & wait $!
	echo -e daemon=1 >> ~/.$datadir/$datadir.conf & wait $!
	echo -e logtimestamps=1 >> ~/.$datadir/$datadir.conf & wait $!
	echo -e maxconnections=256 >> ~/.$datadir/$datadir.conf & wait $!
	echo -e karmanode=1 >> ~/.$datadir/$datadir.conf & wait $!
	#echo -e externalip= >> ~/.$datadir/$datadir.conf & wait $!
	#echo -e karmanodeaddr= >> ~/.$datadir/$datadir.conf & wait $!
	echo -e karmanodeprivkey= >> ~/.$datadir/$datadir.conf & wait $!
	sleep 2
	echo "Your rpcuser is $rpcuser
	echo ""
	echo "Your rpcuser is $rpcpassword"
	echo "Make sure to save your rpc username and password for your cold wallet later"
	echo -n "Press any key to continue"
	echo -n "enter the karmanodeprivatekey		:"
	read -r karmanodeprivkey
	echo "These were your answers		:"
	echo ""
	echo ""
	echo $rpcuser
	echo $rpcpassword
	echo $externalip
	echo $karmanodeprivkey
	sleep 2
	echo "Using your answers to generate the .conf"
	#sed -i '/externalip/c\' ~/.$datadir/$datadir.conf
	#echo "externalip=$externalip:$PORT" >> ~/.$datadir/$datadir.conf
	#sed -i '/karmanodeaddr/c\' ~/.$datadir/$datadir.conf
	#echo "karmanodeaddr=$externalip:$PORT" >> ~/.$datadir/$datadir.conf
	sed -i '/karmanodeprivkey/c\' ~/.$datadir/$datadir.conf
	echo "karmanodeprivkey=$karmanodeprivkey" >> ~/.$datadir/$datadir.conf
	sleep 2
	echo "Configuration completed successfully"
else
        echo "$datadir.conf not found"
	echo "This means the daemon install failed and the daemon didn't run properly"
	echo "Please re-run the script or check the git repo paths are correct"
	echo "Try installing the wallet from the git repo source manually to verify if the error is in this script or the source"
        echo -n "Hit any key to continue        :"
        read -r goodbye
        echo ""
        echo "You will now be sent back to the menu"
        echo "goodbye"
        sleep 5
	echo "done"
}	
	
check_ufw () {	
clear
  echo "Checking firewall ports..."
	sleep 2
	STATUS='ufw status'
	echo $STATUS | grep "$PORT/tcp" > /dev/null
	  if [ $? -gt 0 ]; then
			echo "Adding port $PORT to UFW rules - ufw allow $PORT/tcp"
			ufw allow $PORT/tcp > /dev/null
			echo "$PORT has been allowed"
		else
			echo "Port $PORT already in UFW"
		fi
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
 clear
}

start_karmanode () {
clear
	echo "starting $daemon..."
	$daemon
	echo "Waiting for $DAEMON to start and begin to sync..."
	sleep 2
	echo "While waiting for the chain to sync, continue with the following steps	:"
	sleep 2
	echo "Go to your cold wallet, open Tools > Debug console	"
	echo "enter 	karmanode list-conf     into the console"
	echo ""
	sleep 10
	echo "You should see your karmanode with a status of MISSING"
	echo ""
	sleep 5
	echo ""
	echo "Then select the Karmanode tab, right-click your karmanode alias"
	echo "click Start Alias"
	echo ""
	sleep 5
	echo -n "Hit enter once you have started the karmanode	:"
	read -r enter
	echo ""
	echo "The script will now wait for the local wallet to sync with the chain...please wait"
	Getdiff=5
	IsItSynced() {
	Checkblockchain="wget -O - $getblockcount"
	Checkblockcount="$cli-cli getblockcount"
	Getdiff="expr $Checkblockchain - $Checkblockcount"
	current_date_time="`date "+%Y-%m-%d %H:%M:%S"`";
	sleep 30
	}
	while [[ $Getdiff -gt 1 ]]
	do
	IsItSynced 2>/dev/null
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
	echo "Stopping $daemon..."
	$cli stop
	sleep 10
	echo "Checking if $daemon is still running..."
	SERVICE="$daemon"
	RESULT=`ps -a | sed -n /${SERVICE}/p`
	if [ "${RESULT:-null}" = null ]; then
		echo "$daemon is not running"
	else
		echo "Forcing $daemon to stop"
		killall -9 $datadir`d`
	fi #end if RESULT:-null
	sleep 5
	echo "deleting mncache file..."
	rm ~/.$datadir/mncache.dat -rf
	sleep 2
	echo "Starting $daemon"
	$daemon start
    	echo "Please wait 30 seconds"
	sleep 30
	echo "Running mnsync reset"
	$cli mnsync reset
	echo "This should force the wallet to grab the latest list of current running karmanodes"
	echo "Waiting for mnsync to complete...please wait"
	sleep 30
	$cli getinfo
	$cli karmanode status
	sleep 5
	echo "Hopefully by now you should see your karmanode above" 
	sleep 2
	echo "if not check your cold wallet's status or try '$cli karmanode status' again, or restart if you still can't see it"
	echo ""
	sleep 2
	cat ~/.$datadir/debug.log | grep CActivekarmanode::EnableHotColdkarmanode
	sleep 2
	echo "You should see the enabled message above, if not you will need to troubleshoot further"
	sleep 5
	echo ""
	echo "If this helped you please consider donating here for my efforts	:"
	read -r goodbye
	echo ""
	echo "You will now be sent back to the menu"
	echo "goodbye"
	sleep 5
} # end the start_karmanode function

upgrade () { 
clear
echo "Checking ~/.$datadir/$datadir.conf exists" & wait $!
if [ -f ~/.$datadir/$datadir.conf ]; then
	echo "$datadir.conf exists!"
	echo "Proceeding with upgrade..."
	sleep 2
	install
	start_karmanode
else
	echo "$datadir.conf not found"
	echo "You either have a custom install in a custom location..."
	echo "...or you have not installed a karmanode yet..."
	echo -n "Hit any key to continue	:"
	read -r goodbye
	echo ""
	echo "You will now be sent back to the menu"
	echo "goodbye"
	sleep 5
fi # end if $datadir.conf exists	
} # end the upgrade

check_iptables () { 
clear
	echo "Checking firewall ports..."
	sleep 2
	if [ "iptables -L INPUT -nv | grep -q $PORT" ]
	then 
		echo "Port $PORT already in iptables"
	else
		echo "Adding iptables rules - iptables -I INPUT -p tcp --dport $PORT -j ACCEPT"
		iptables -I INPUT -p tcp --dport $PORT -j ACCEPT
		service iptables save
	fi
	echo "Checking SSH port in config..."
	ssh=`grep -r Port /etc/ssh/sshd_config | awk '{print $2}'`
	echo "SSH port is port $ssh..."
	if [ "iptables -L INPUT -nv | grep -q $ssh" ]
	then
		echo "Port $ssh already in iptables"
	else
		echo "Adding ssh port to iptable rules - iptables -I INPUT -p tcp --dport $ssh -j ACCEPT"
		iptables -I INPUT -p tcp --dport $ssh -j ACCEPT
		service iptables save
	fi
	echo ""
	echo "IPtables checked and saved"
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
	./configure --without-gui --disable-wallet
	make
	make install
	echo "$COIN installed"
	sleep 2
	$daemon
	echo "$daemon has been run once, it should have created the .$datadir directory"
	sleep 2
	cd ..
	rm -rf ~/$gitdir
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
if [ ! -e /etc/apt/sources.list.d/bitcoin-bitcoin-trusty.list ]
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
	echo "This is Ubuntu 14.04"	
	echo "Installing $COIN on 14.04.from scratch"
	libzmq="libzmq3"
	run_apt
	check_ufw
fi # ends the 14.04 if-statement
if grep -q 16.04 /etc/*elease
then
	echo "This is Ubuntu 16.04"
	echo "Installing $COIN on 16.04 from scratch"
	libzmq="libzmq3-dev"
	run_apt
	check_ufw
fi # ends the 16.04 if-statement
if grep -q centos /etc/*elease
then
	echo "This is CentOS"
	echo "Installing $COIN on CentOS from scratch"
	run_yum
	check_iptables
fi
if ! grep -q 14.04 /etc/*elease && ! grep -q 16.04 /etc/*elease && ! grep -q centos /etc/*elease;
then
	echo "This is an unsupported OS" 
fi # end unsupported OS check
git_install
configure
start_karmanode
} # end the karmanode_install function



######## ======== UPGRADE FUNCTIONS ======== ########
upgrade_karmanode () {
clear
	echo "This will upgrade your karmanode"
	echo "Replacing your existing $daemon and $cli with the latest available"
	sleep 5
	echo "Checking if $daemon is running..."
	SERVICE="$daemon"
	if [ -f /etc/systemd/system/$COIN.service ]; then
		echo "$COIN Systemd service found!"
		systemctl status $COIN.service
		echo "Current staus of service above"
		sleep 5
		if [ "systemctl status $COIN.service | grep running" ]; then
			echo "Stopping $COIN via systemd script"
			systemctl stop $COIN.service
			sleep 5
			RESULT=`ps -ef | sed -n /${SERVICE}/p`
			if [ "${RESULT:-null}" = null ]; then
				echo "$COIN is not running"
			else
				echo "Stopping $daemon forcefully"
				killall -9 $daemon
			fi # end if RESULT
		else
			echo "$COIN is not running"
			sleep 5
		fi # end $COIN.service running
	else
		RESULT2=`ps -ef | sed -n /${SERVICE}/p`
		if [ "${RESULT2:-null}" = null ]; then
			echo "$daemon is not running"
		else
			echo "Stopping $daemon"
			$cli stop
			sleep 3
			RESULT3=`ps -ef | sed -n /${SERVICE}/p`
			if [ "${RESULT3:-null}" = null ]; then
				echo "$daemon is not running"
			else
				echo "Stopping $daemon forcefully"
			killall -9 $daemon
			fi # end if RESULT3
		fi # end if RESULT2
	fi	# end if shekel.service exists
if grep -q 14.04 /etc/*elease # This checks if the release file on the server reports Ubuntu 14.04, if not it skips this section
then
	echo "This is Ubuntu 14.04"	
		echo "Upgrading $COIN on 14.04"
		libzmq="libzmq3"
		echo "Patching system..."
		# Patches the system, installs required packages and repositories
		run_apt
		echo "Installed any missing packages"
		# Downloads and extracts the current latest release, moves to the correct location then runs $daemon
		git_install
		echo "Latest $daemon installed"
		sleep 2
		if [ -f /etc/systemd/system/$COIN.service ]; then
			echo "$COIN Systemd service found!"
			systemctl status $COIN.service
			echo "Current staus of service above"
			sleep 5
			echo "Starting $COIN via systemd script"
			systemctl start $COIN.service
			sleep 5
		else
			echo "Starting $daemon..."
			$daemon start
				sleep 2
		fi
fi # ends the 14.04 if-statement
if grep -q 16.04 /etc/*elease # This checks if any release file on the server reports Ubuntu 16.04, if not it skips this section
then
	echo "This is Ubuntu 16.04"
		echo "Installing $COIN on 16.04 from scratch"
		libzmq="libzmq3-dev"
		echo "Patching system..."
		# Patches the system, installs required packages and repositories
		run_apt
		echo "Installed any missing packages"
		# Downloads and extracts the current latest release, moves to the correct location then runs $daemon
		git_install
		echo "Latest $daemon installed"
		sleep 2
		if [ -f /etc/systemd/system/$COIN.service ]; then
			echo "$COIN Systemd service found!"
			systemctl status $COIN.service
			echo "Current staus of service above"
			sleep 5
			echo "Starting $COIN via systemd script"
			systemctl start $COIN.service
			sleep 5
		else
			echo "Starting $daemon..."
			$daemon start
				sleep 2
		fi
fi # ends the 16.04 if-statement
if grep -q centos /etc/*elease # This checks if any release file on the server reports Centos, if not it skips this section
then
	echo "This is CentOS"
		echo "Installing $COIN on CentOS from scratch"
		run_yum
		echo "Installed any missing packages"
		git_install
		echo "Latest $daemon installed"
		sleep 2
		if [ -f /etc/systemd/system/$COIN.service ]; then
			echo "$COIN Systemd service found!"
			systemctl status $COIN.service
			echo "Current staus of service above"
			sleep 5
			echo "Starting $COIN via systemd script"
			systemctl start $COIN.service
			sleep 5
		else
			echo "Starting $daemon..."
			$daemon start
				sleep 2
		fi
	if ! grep -q 14.04 /etc/*elease && ! grep -q 16.04 /etc/*elease && ! grep -q centos /etc/*elease;
	then
		echo "This is an unsupported OS" 
		# If the above two checks fail, i.e the lsb_release file does not show a supported version of Ubuntu, or any other linux, it will not support it and halt the script from making any changes
	fi # end unsupported OS check	
fi # end the centos check if-statement
}  # end the karmanode_upgrade function


install_service () {
clear
echo "Installing systemd script to start at boot and start $daemon...please wait"
sleep 5
cat <<EOF > /etc/systemd/system/$COIN.service
[Unit]
Description=$COIN's distributed currency daemon
After=network.target

[Service]
User=$USER


Type=forking
PIDFile=~/.$datadir/$daemon.pid
ExecStart=/usr/local/bin/$daemon -daemon -pid=~/.$datadir/$daemon.pid -conf=~/.$datadir/$datadir.conf -datadir=~/.$datadir
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
systemctl enable $COIN.service
echo "Script enabled"
sleep 3
echo "Checking if $daemon is running..."
SERVICE="$daemon"
RESULT=`ps -a | sed -n /${SERVICE}/p`
if [ "${RESULT:-null}" = null ]; then
    echo "$COIN is not running"
else
    echo "Stopping $daemon"
    $cli stop
    sleep 3
    RESULT2=`ps -a | sed -n /${SERVICE}/p`
    if [ "${RESULT:-null}" = null ]; then
    	echo "$COIN is not running"
    else
        echo "Stopping $daemon"
	killall -9 $daemon
    fi
fi
echo "Starting the $COIN.service service"
echo "Please wait 30 seconds"
systemctl start $COIN.service
sleep 30
echo "Service should have started which you can see below"
echo ""
systemctl status $COIN.service
sleep 3
echo "The service should show green above"
echo ""
sleep 3
echo "Status of shekel-cli getinfo..."
sleep 1
$cli getinfo
sleep 1
echo "Status of karmanode status"
$cli karmanode status
sleep 3
echo "done"
echo ""
echo "Going back to main menu"
sleep 3
}

install_check () {
echo "Creating check.sh in $USER's home directory"
echo -n "Please paste your wallet address holding your $COIN collateral	:"
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
=== $daemon not running...restarting ===
========================================
'
rm ~/.$datadir/mncache.dat -rf
systemctl start $daemon
sleep 30
echo ""
echo ""
echo "==== getinfo OUTPUT ===="
   $cli getinfo
echo "==== getinfo OUTPUT ===="
echo ""
echo ""
  sleep 30
echo "==== karmanode status OUTPUT ===="
$cli karmanode status
echo "==== karmanode status OUTPUT ===="
echo ""
echo ""
echo "==== karmanode list OUTPUT ===="
$cli karmanode list $add
echo "==== karmanode list OUTPUT ===="
echo ""
echo ""
echo "==== debug.log OUTPUT ===="
cat ~/.$datadir/debug.log | grep CActivekarmanode::EnableHotColdkarmanode
echo "==== debug.log OUTPUT ===="
echo ""
echo ""
echo "You should see the following message above	:	"
echo "Enabled! You may shut down the cold daemon."
echo ""
echo "This means the karmanode is Enabled"
echo ""
echo ""
}

trap 'abort' 0

set -e

running=`$cli getinfo | grep version`
if [[ $running == *"version"* ]]; then
   echo "$COIN RUNNING!"
   echo "============"
echo ""
echo ""
echo "==== getinfo OUTPUT ===="
   $cli getinfo
echo "==== getinfo OUTPUT ===="
echo ""
echo ""
  sleep 30
echo "==== karmanode status OUTPUT ===="
$cli karmanode status
echo "==== karmanode status OUTPUT ===="
echo ""
echo ""
echo "==== karmanode list OUTPUT ===="
$cli karmanode list $add
echo "==== karmanode list OUTPUT ===="
echo ""
echo ""
echo "==== debug.log OUTPUT ===="
cat ~/.$datadir/debug.log | grep CActivekarmanode::EnableHotColdkarmanode
echo "==== debug.log OUTPUT ===="
echo ""
echo ""
echo "You should see the following message above	:	"
echo "Enabled! You may shut down the cold daemon."
echo ""
echo "This means the karmanode is Enabled"
echo ""
echo ""
fi

check=`$cli karmanode list $add | grep ENABLED`
echo $check
if [[ $check == *"POS_ERROR"* ]]; then
   echo "POS ERROR!"
   systemctl stop $daemon
   sleep 30
   rm ~/.$datadir/mncache.dat -rf
   systemctl start $COIN
   sleep 30
echo ""
echo ""
echo "==== getinfo OUTPUT ===="
   $cli getinfo
echo "==== getinfo OUTPUT ===="
echo ""
echo ""
  sleep 30
echo "==== karmanode status OUTPUT ===="
$cli karmanode status
echo "==== karmanode status OUTPUT ===="
echo ""
echo ""
echo "==== karmanode list OUTPUT ===="
$cli karmanode list $add
echo "==== karmanode list OUTPUT ===="
echo ""
echo ""
echo "==== debug.log OUTPUT ===="
cat ~/.$datadir/debug.log | grep CActivekarmanode::EnableHotColdkarmanode
echo "==== debug.log OUTPUT ===="
echo ""
echo ""
echo "You should see the following message above	:	"
echo "Enabled! You may shut down the cold daemon."
echo ""
echo "This means the karmanode is Enabled"
echo ""
echo ""

echo $check

fi
if [[ $check == *"ENABLED"* ]]; then
   echo "$COIN ENABLED!"
echo ""
echo ""
echo "==== getinfo OUTPUT ===="
   $cli getinfo
echo "==== getinfo OUTPUT ===="
echo ""
echo ""
  sleep 30
echo "==== karmanode status OUTPUT ===="
$cli karmanode status
echo "==== karmanode status OUTPUT ===="
echo ""
echo ""
echo "==== karmanode list OUTPUT ===="
$cli karmanode list $add
echo "==== karmanode list OUTPUT ===="
echo ""
echo ""
echo "==== debug.log OUTPUT ===="
cat ~/.$datadir/debug.log | grep CActivekarmanode::EnableHotColdkarmanode
echo "==== debug.log OUTPUT ===="
echo ""
echo ""
echo "You should see the following message above	:	"
echo "Enabled! You may shut down the cold daemon."
echo ""
echo "This means the karmanode is Enabled"
echo ""
echo ""

fi

trap : 0

EOF

if [ "$email" != "" ]
then
	chmod +x ~/check.sh
	sudo -u $USER crontab -l > mycron
	echo "*/30 * * * * ~/check.sh 2>&1 | tee output.txt | mail -s '$datadir karmanode status' $email"
	sudo -u $USER echo -e "*/30 * * * * ~/check.sh 2>&1 | tee output.txt | mail -s '$datadir karmanode status' $email" >> mycron
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
   echo "e.g sudo ./install_karmanode.sh"
   echo "this script will now exit"
   exit 1
fi
}
################ ================ MENU ================ ################
menu () {
while :
do
    clear
echo "===================================================="
echo "==          karmanode Wallet Installer            =="
echo "==      For Ubuntu 14.04 or 16.04 or CentOS7      =="
echo "==                  version 1.0                   =="
echo "==                                                =="
echo "== Please donate:                                 =="
echo "== Bitcoin:  19rUHQQ2PNGzGzvLgoY9SiEwUCcNxJ2cqT   =="
echo "== Litecoin: LiBKYy6ZpCzTPpkqYaHPmjfuiQiLvxkNDE   =="
echo "== Shekel:   JQJ1GanDU3c5RZwNjBXk68wFdxEJKLwWZU   =="
echo "== Ohm:      ZFjLmdQittBwSmJMCAHQkQfbuNV4Gs2vUu   =="
echo "==                                                =="
echo "==         Copyright Cryptojatt(c) 2018           ==" 
echo "==        https://github.com/cryptojatt           =="
echo "----------------------------------------------------"
echo ""
echo "Please consider donating for my time and effort in put into this	:" 
echo ""
sleep 1
amiroot
cat <<EOF
    Please enter your choice:

    Install Wallet & Set Up karmanode  (1)
    Upgrade Wallet & Start karmanode   (2)
    Install Systemd Service	       (3)
    Install check script	       (4)
           			       (Q)uit
    ------------------------------
EOF
    read -n1 -s
    case "$REPLY" in
    "1")  install ;;
    "2")  upgrade ;;
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
