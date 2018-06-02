Boot from ISO and then at the Setup menu hit the tab key, then hit F6 and change the line to look like this:


append preseed/url=http://preseed.handsoff.local/ubuntu16.cfg vga=788 netcfg/choose_interface=auto initrd=/install/initrd.gz priority=critical --
