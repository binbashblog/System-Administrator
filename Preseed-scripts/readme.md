# Preseed Scripts

## Usage:

Store your preseed.cfg customised to your needs on a web server reachable on port 80.

Boot from ISO and then at the Setup menu hit the tab key, then hit F6 and change the line to look like this, obviously changing the url to the correct one:

```
append preseed/url=http://preseed.handsoff.local/ubuntu16.cfg vga=788 netcfg/choose_interface=auto initrd=/install/initrd.gz priority=critical --
```

Store the .sh scripts too, modify them for your own use. These post install scripts get your system ready, you can then template it up in your favourite Virtual or Cloud provider.

For newer Ubuntu releases 18.04 LTS and higher, I use the alternative installer iso with the older installer which works with preseed better than the new one.
