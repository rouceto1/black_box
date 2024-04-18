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
Unplug the LAN cable, wait for 5 seconds and plug it back. Go to https://192.168.2.1 to check the LAN IP change has been successful. It might happen the browser
won't be able to connect. In such case, SSH to the router with `ssh root@192.168.2.1` (this should work) and call `/etc/init.d/lighttpd restart`.

At https://192.168.2.1/reforis/network-settings/guest-network disable Guest network.

Configure the flash drive for storing large or often changing data. The drive should be plugged into the front USB port. Go to https://192.168.2.1/reforis/storage .
In section "Prepare drives" check `sda1` and click "Format&Set". It will get stuck at "Formatting", but you should see a reboot notification popping up in Reforis.
Do the reboot. After the reboot, the same Reforis page should say "Device currently in use is /dev/sda1".

Go to https://192.168.2.1/reforis/sentinel/agreement and accept the dynamic firewall license agreement. Now you should see 3 green checkmarks on the Overview page.

SSH to the router via `ssh root@192.168.2.1` and perform these commands to run the install script:

```bash
opkg update
opkg install git
opkg install git-http
cd
git clone https://github.com/ctu-vras/robot-connection-box.git
# clone the repo with your private configs and symlink its local-config.bash file into ~/robot-connection-box/omnia/local-config.bash
~/robot-connection-box/omnia/install.sh  # Pay attention to whatever the script is saying
reboot
```

Go over to https://192.168.2.1/cgi-bin/luci/admin/network/wireless and configure the upstream wifi by clicking Add next to radio2.
In General setup, change Mode to Client and enter the SSID. In Network, choose `wwan` and `wwan6`. On Wireless security tab, configure the authentication. Click Save and then Save & Apply.
You should also remove the default-generated SSIDs called "Turris" or "?". Save & apply.

## Updating the router

SSH to the router and:

```bash
cd ~/robot-connection-box
git pull
# also update your private config repo if needed
./omnia/install.sh
```
