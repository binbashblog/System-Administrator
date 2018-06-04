#!/bin/bash

# This script will run the first time the system boots. Even
# though we've told it to run after networking is enabled,
#
# Introducing a brief sleep makes things work right all the
# time. The time for DHCP to catch up.
#sleep 120

## Debian Preseed :: First Boot script


# Change pinda password with SHA-512 encrypted hash

echo 'user:saN0NMA5ST./k' | chpasswd -e

cat <<EOF > /etc/netplan/01-netcfg.yaml

network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: no
      dhcp6: no
      addresses: [10.0.3.17/24]
      gateway4: 10.0.3.254
      nameservers:
        addresses: [10.0.3.5,10.0.3.6]
EOF

netplan apply

cat <<EOF > /etc/hostname
ubuntu-server
EOF
# set hostname
echo $hostname > /etc/hostname
#/etc/init.d/hostname.sh

# OpenSSH Server configuration
rm /etc/ssh/ssh_host_*

declare -A keytypes=(\
        ["ed25519"]="256" \
        ["ecdsa"]="521" \
        ["rsa"]="4096" \
        ["dsa"]="1024")

for type in ${!keytypes[@]}
do
        KEYPATH="/etc/ssh/ssh_host_${type}_key"
        ssh-keygen -q -t ${type} -b ${keytypes["$type"]} -C "" -N "" -f ${KEYPATH}
done

cat <<EOF > /etc/ssh/sshd_config
Port 22
Protocol 2
HostKey /etc/ssh/ssh_host_ed25519_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_dsa_key
SyslogFacility AUTH
LogLevel INFO
LoginGraceTime 60
AllowUsers ubuntu-user
PermitRootLogin no
UsePAM yes
PermitEmptyPasswords no
UsePrivilegeSeparation yes
StrictModes yes
IgnoreRhosts yes
PubkeyAuthentication yes
HostbasedAuthentication no
ChallengeResponseAuthentication yes
PasswordAuthentication yes
X11Forwarding no
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
MaxStartups 4
Compression yes
ClientAliveCountMax 3
ClientAliveInterval 15
IPQoS cs4 8
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
EOF


cat <<EOF > /etc/hosts
127.0.0.1       ubuntu-server ubuntu-server.ubuntu.local
EOF

cd /var/tmp

#Install all updates
#apt-get -y upgrade
#apt-get -y dist-upgrade
#apt-get -y autoremove

#wget https://apt.puppetlabs.com/puppetlabs-release-pc1-bionic.deb
#dpkg -i puppetlabs-release-pc1-bionic.deb

#cat <<EOF > /etc/apt/preferences.d/00-puppet.pref

#Package: puppet
#Pin: version 3.8*
#Pin-Priority: 501
#EOF

#gpg --keyserver keys.gnupg.net --recv-keys F8C1CA08A57B9ED7
#gpg --armor --export F8C1CA08A57B9ED7 | apt-key add -

#cat <<EOF > /etc/apt/sources.list.d/omd-stable.list
#deb http://labs.consol.de/repo/stable/debian jessie main
#EOF

apt-get update

DEBIAN_FRONTEND=noninteractive apt-get -y install postfix ufw monit fail2ban puppet

cd /tmp
ufw limit 22/tcp
#ufw allow 80/tcp
#ufw allow 6556/tcp
ufw enable

apt-get -y upgrade
apt-get -y dist-upgrade
apt-get -y autoremove
apt-get -y clean
ufw logging on
#Systemctl configuration
cat <<EOF > /etc/sysctl.conf
#
# /etc/sysctl.conf - Configuration file for setting system variables
# See /etc/sysctl.d/ for additional system variables
# See sysctl.conf (5) for information.
#
# Uncomment the next two lines to enable Spoof protection (reverse-path filter)
# Turn on Source Address Verification in all interfaces to
# prevent some spoofing attacks
net.ipv4.conf.default.rp_filter=1
net.ipv4.conf.all.rp_filter=1
# Uncomment the next line to enable TCP/IP SYN cookies
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 5
# Do not accept ICMP redirects (prevent MITM attacks)
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
# Do not send ICMP redirects (we are not a router)
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
# Do not accept IP source route packets (we are not a router)
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0
# Log Martian Packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
# Ignore ICMP broadcast requests
net.ipv4.icmp_echo_ignore_broadcasts = 1
# Ignore Directed pings
net.ipv4.icmp_echo_ignore_all = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-filter-pppoe-tagged = 1
net.bridge.bridge-nf-filter-vlan-tagged = 1
net.core.default_qdisc = code1
net.ipv4.conf.all.force_igmp_version = 2
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.all.secure_redirects = 1
net.ipv4.tcp_ecn = 1
net.ipv4.tcp_rfc1337 = 1
vm.swappiness = 0
EOF

echo "tmpfs     /dev/shm     tmpfs     defaults,noexec,nosuid     0     0" >> /etc/fstab

echo "noop" > /sys/block/sda/queue/scheduler

# Enable log compression
sed -i 's/#compress/compress/' /etc/logrotate.conf

# Tweak initramfs generation
sed -i 's/COMPRESS=gzip/COMPRESS=yx/' /etc/initramfs-tools/initramfs.conf
sed -i 's/MODULES=most/MODULES=dep/' /etc/initramfs-tools/initramfs.conf
update-initramfs -u -k all

# get IPMI ip and detect hostname
#ipmi_ip=`ipmitool lan print | grep "IP Address  " | sed 's/.*: //'`
#hostname=`grep $ipmi_ip /tmp/ipmilist | awk '{print $1}'`
#rm /tmp/ipmilist

puppet agent --enable
puppet agent --verbose --no-daemonize --certname=`cat /etc/hostname` --waitforcert 5 --onetime --server puppet01

# Capture a log output of the firstboot service
journalctl --unit=firstboot > /root/firstboot.log

# Remove our firstboot service so that it won't run again
systemctl disable firstboot
rm /etc/systemd/system/firstboot.service /root/firstboot

# Reboot
reboot now


