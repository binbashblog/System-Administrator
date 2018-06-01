#!/bin/sh

# grab our firstboot script
/usr/bin/curl -o /root/firstboot http://192.168.3.25/ubuntu.sh
chmod +x /root/firstboot

# create a service that will run our firstboot script
cat <<EOF > /etc/systemd/system/firstboot.service
[Unit]
Description=FirstBoot Service
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/root/firstboot

[Install]
WantedBy=multi-user.target
EOF

# install the firstboot service
systemctl enable firstboot

echo "finished postinst"

