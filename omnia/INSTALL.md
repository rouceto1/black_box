# Installation guide for the Turris Omnia router

## Initial setup

Before doing the initial software setup, you have to properly finish the hardware setup of the router's internals and antennas. All antennas have to be connected
for the duration of the initial setup, but you can use temporary replacements (e.g. the antennas that came with the router) if it is more suitable.
You can do this initial setup with the router sitting on a table, it doesn't need to be inside the box.

The web GUI Reforis doesn't work on Windows when Avast or AVG antiviruses are installed. Either do the configuration from Linux, from a phone, or temporarily disable
SSL/HTTPS scanning in the antiviruses.

When connecting a brand new Omnia, there is a setup guide you have to go through.
Connect a cable with Internet to the WAN port. Connect your computer to one of the LAN ports, use DHCP client to get an address and go to https://192.168.1.1 .
This will run the guide. Configure the Omnia as a Router, set up WAN to DHCP, DNS, NTP so that it works for the time of initial setup.
The proper values for field use will be set up later using a configuration script. When configuring updater, set it to require update approvals.

Once the setup guide finishes, it installs updates. But we have set update approvals, so you have to go again to https://192.168.1.1, log in with the
configured password and go to https://192.168.1.1/reforis/package-management/updates . Here, click "Install now" to install the updates.
This will probably take a few minutes. You can check the status either by waiting for a notification on the Overview page, or you can ssh to the router
as `ssh root@192.168.1.1` (and the password you configured in the guide for advanced administration) and run `tail -f /var/log/messages` and wait for message from
the updater that it has finished: `updater-supervisor: pkgupdate reported no errors`.
If you're waiting for the notification in GUI and it doesn't pop up, reload the page from time to time. The update can shut down the webserver so there is
nothing that would send you the notification. Reloading the web GUI triggers a start of the web server.
Reboot.

Wait for the reboot and go again to https://192.168.1.1/reforis/package-management/updates . Check for updates again and approve the update if there is anything pending.
Wait for the update to finish.

Go to https://192.168.1.1/reforis/package-management/packages and check Latest firmware -> Factory image and MCU. Do not check U-Boot and rescue image yet.
Once you save the selection, go again to the updates page and approve the update. Wait for the update to install. The router will start blinking all LEDs green.
Reboot the router and when the LEDs go to knight-rider instead of green blinking, unplug it from power and plug it back.

There is a bug that the LEDs might not be lit after the start. But do not worry - the router actually booted! Just press the button on the front panel and the LEDs will work again.

Now SSH to the router with `ssh root@192.168.1.1` and run `tail -f /var/log/messages`. In the web GUI, go to https://192.168.1.1/reforis/package-management/packages
and select Latest firmware -> U-Boot and rescue image. Again, go to the updates page and approve the update. Switch to the SSH console and carefully watch the output.
Now pray to see `updater-supervisor: pkgupdate reported no errors` (it will take a few minutes, most of them spent in `Executing postupdate hook: 96_firmware_updater`).
Reboot. If the router doesn't boot, the bootloader update failed. In such case, you have to disassemble the Omnia, connect a USB-UART conversion and save the router
following the guide here: https://docs.turris.cz/hw/omnia/serial-boot/ .

Now you should have the Omnia ready with the latest OS, bootloader and MCU firmware.
MCU firmware can be tested with `omnia-mcutool -v`. If the command doesn't fail, you have a good firmware.
Bootloader version can be read from the output of `strings /dev/mtd0 | grep U-Boot`. If you see `U-Boot SPL 2022.10` or newer, you're good.

Now, configure the LAN. Go to https://192.168.1.1/reforis/network-settings/lan and change "Router IP address" to 192.168.2.1 (or any other value you want).
Change "DHCP start" to 192.168.2.10 (or anything other that you desire) and "DHCP max leases" to 240 (beware that the start + max has to sum to a number lower than 255).
Unplug the LAN cable, wait for 5 seconds and plug it back. Go to https://192.168.2.1 to check the LAN IP change has been successful. It might happen the browser
won't be able to connect. In such case, SSH to the router with `ssh root@192.168.2.1` (this should work) and call `/etc/init.d/lighttpd restart`.

Now configure the client wifi. Go to https://192.168.2.1/reforis/network-settings/wifi and click "Reset Wifi settings". This will make sure the wifi cards are correctly enumerated.
Wifi 1 is the 2.4 GHz AP for your clients, Wifi 2 is the 5 GHz AP for you clients, and Wifi 3 is the upstrean (WWLAN) card that cannot be configured in Reforis.
Configure Wifi 1 and Wifi 2 as needed. For Wifi 2, it is not suggested to use 80 MHz channels as it increases sensitivity to noise.

In https://192.168.2.1/reforis/network-settings/dns turn on "Enable DHCP clients in DNS".

At https://192.168.2.1/reforis/network-settings/guest-network disable Guest network.

At https://192.168.2.1/reforis/administration/hostname change the hostname of the router. We use `blackbox-N` where N is the number of the box.

Configure the flash drive for storing large or often changing data. The drive should be plugged into the front USB port. Go to https://192.168.2.1/reforis/storage .
In section "Prepare drives" check `sda1` and click "Format&Set". It will get stuck at "Formatting", but you should see a reboot notification popping up in Reforis.
Do the reboot. After the reboot, the same Reforis page should say "Device currently in use is /dev/sda1".

Go to https://192.168.2.1/reforis/package-management/packages and check "Advanced security & analysis". You can uncheck "Usage Survey" if you want. Uncheck "Minipots".
Also check "Luci extensions" -> "Wireguard". Check "LXC Utilities".
Check "Netowrk monitoring" and inside that, check "Internet connection speed measurement" and "New devices detection".
Click Save and approve the update. When it is finished, reboot the router.

Go to https://192.168.2.1/reforis/sentinel/agreement and accept the dynamic firewall license agreement. Now you should see 3 green checkmarks on the Overview page.

Now go to https://192.168.2.1/cgi-bin/luci/admin/system/system, log in with the password for advanced administration and change language to English.

Go to https://192.168.2.1/cgi-bin/luci/admin/network/network and configure the network device for upstream wifi. Click Add new interface. Choose type "DHCP client".
In Device, go the the bottom to the Custom field and type `wlan2`.
Create interface. In Advanced settings, set "Use gateway metric" to 150. In Firewall tab, assign it to WAN zone.
Add new interface again. Name `wwan6`, Protocol DHCPv6 client, Device `@wwan`. Again, Gateway metric 150 and WAN zone. Save & apply.

Go over to https://192.168.2.1/cgi-bin/luci/admin/network/wireless and configure the upstream wifi by clicking Add next to radio2.
In General setup, change Mode to Client and enter the SSID. In Network, choose `wwan` and `wwan6`. On Wireless security tab, configure the authentication. Click Save and then Save & Apply.
You should also remove the default-generated SSIDs called "Turris" or "?". Save & apply.

Go to https://192.168.2.1/cgi-bin/luci/admin/network/network again, click Edit next to "wan" and set gateway metric to 100. Save & apply.
