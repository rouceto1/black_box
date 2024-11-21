[Assembly model](https://a360.co/3UheEoB)
[BOM](https://docs.google.com/spreadsheets/d/1pW8I78pGmDZeQg6-AQzk0oum4GO72B5RDJt2gy8QRNQ/edit?usp=sharing)


The box consists of 4 main components: 

Omnia
Power distribution
GPS
RF (Antenna and bullet)

## Overview 
The box provides client WiFi (TRADR-CTU) using Omnia Wi-Fi that is added. 
Users are supposed to use this network to connect to the black box. 

The box connects to robots either using the TRADR-CTU WiFi or the included Ubiquity Bullet device that each robot carries. 

#### Netwroking
Each client (Wifi/Bullet/Cable) receives an 192.168.2.* address from available pool using DHCP. 
These addresses can be fixed upon request. 
The main device (Omnia) has 192.168.2.1.

Users can connect using Wi-Fi or Etherent cable at the back of the box that also gives the same DHCP. 

The black box also uses Ethernet, other Wi-Fi or LTE to connect to the internet with the descending priority. 

#### Power

The box can be run on external power or use one or two Parkside batteries.
System is compatible with all Parkside batteries but expected battery life is about 12 hours on 2x 8Ah batteries.
There is a built in charge indicator on the batteries but the box will sound an audible alarm when the charge gets low. 
The box cal also charge the batteries inside with another adapter. 

The batteries should not be left in the box long term but overnight storage is OK.

#### Accercories
The box has a compartment for a power supply, two batteries, GPS antenna, GPS antenna ground plane, GPS antenna pole and KVM module that can be used to control any PC using a laptop.

## Build guide
Parts required are listed in THIS file.
The box can be built without GPS capability and without accessories and will function just fine.  

#### Omnia

1. Remove the whole board from housing and all the cables.
2. Mount all cards and heatsinks to the board
	1. Insert SIM card to the spot closest to the side
	2. Mount LTE modem to the same slot
	3. Mount the 4 tail WiFi to the middle slot
	4. Mount the 2 tail WiFi to the slot furthest from the side
	5. Remove protective cover and mount two black heatsinks onto the WIFi cards
	6. Stick the aluminum block included with the LTE modem to the modem
		1.  Use the thin pad to stick the block to the LTE
		2. Use the thick pad on top of the block
		3. DO NOT FORGET to remove the plastic cover from the block afterwards
3. Drill 4 holes to the rear panel between existing ones using 6.2 drill
4. Mount the whole board back to the panel. 
	1. DO NOT FORGET to remove the plastic cover from the fluffy pad under the board
5. Screw in the SMA connectors to the rear panel 
	1. Starting from one side the order is alternating SMA - RP SMA - SMA - RP SMA
	2. The other half is the same but front he other side of the box
	3. Middle hole remain open for access to the GPIO
6. Connect the SMA connectors to their respected devices
	1. The order form one side is LTE - 4 tail WiFi - 2 tail WiFi - 4 tail WiFi
	2. The other half is the same but front he other side of the box   
	3. If this is not adhered to the final connection of all the devices in the box will be different
7. Place the LED separator over the LEDs 
8.  Close the box. 
9. Insert the USB stick
10. Use thumbscrews from each side to attach the plastic mounting

#### Box preparation
##### RF mounting
1. Make 3 holes for N pass throughs
	1. Use m16 drill
	2. Middle one runs through the middle and center of the hole is 61mm from the lip  
	3. All other are ~58m from the lip and ~90mm from the center line  
2. Make hole for LED light
	1. Use 22 or 23mm drill
	2. In the middle 20mm from the lip
3. Mount the N-N bulkhead connector with the washers inside the box to the middle hole. 
4. Prepare the Bullet mount 
	1. Place bullet without end cap to the cradle for it
	2. Secure with 2 zip ties 
	3. Place Septentrio GPS and secure with m2.5x5 screws
	4. Place a POE adapter and secure it with m4x(8/6) screws
	5. Connect USB cable to the GPS
	6. Connect the short RF cable to the GPS
5. Screw assembled Bullet mount to the middle bulkhead
6. Drill m3 holes where the elongated slots are currently located
7. Secure the bullet mount using m3x(16/14) screws and nuts (temporarily only or use nylon nuts and silicon around the screw).

8. Prepare mount for Omnia
	1. Drill 4 holes according to drawing using 6.5mm
	2. Mount  plastic side rails for each side using m5x16 screws (temporarily only or use nylon nuts and silicon around the screw).

9. Drill holes for GPS bulkhead on side of the box
	1. Hole is 1cm from lip of closing buckle and 7cm from the top of the box.
	2. Use 7.9mm dril
	3. Attach GPS bulkhead to this hole with gasket from outside
	4. Connect the GPS RF cable to this bulkhead.

10. Prepare client Wifi antennas
	1. Print and attach 2 lower and upper mount on all 4 antennas (two left two right facing
	2. add adhesive tape to each mount 
	3. Attach 10 and 30 cm cables to each left and right set

#####  Power mounting

1. Prepare battery PCB
	1. Solder RED (battery +) and BLACK (battery -) wires to the bottom output terminals of each board and leave ~10cm of the wire dangling on each
	2. Insert 5A fuse car fuse
2. Prepare battery assembly
	1. Mount power distribution PCB to the mount using m3x8 screws.
	2. Sandwich the battery PCB between mounts A and B for both batteries
	3. Shorten the cables to length and connect battery + and - to the board according to the pinout instructions
5. Prepare stabilizing feet.
	1. Use Both feet and aligning tool to mark 8 holes on bottom side of the box 
	2. Drill all 8 holes using 6mm drill

7. Prepare front panel 
	1. Remove the overpressurization outlet
	2. USE the rubber gasket for the LED light 
	3. Drill according to the drilling scatch holes:
		1. Power connector in the original outlet- drill: 12mm
		2. Ethernet bulkhead 25mm from top lip and 20mm from left wall- Drill: 21mm
		3. Button 25mm from top lip and 20mm from right wall-  Drill: 19mm
9. Prepare other cabling 
	1. Remove silicon cover from power connector
	2. Solder wires as per WIRING DIAGRAM to the pins of the power connector
	3. Use a cabling sheet to bunch cables together.


###  Assembly

'Each screw that goes though the body of the box should have the hole first filled with silicone to make the box watertight. All nuts used should have nylon insert.'

  

1. Install front panel
	1. Install power button to the rightmost hole in front panel
	2. Install power connector to the middle hole in front poannel
		1. Remove the silicon cap (will be installed later)
	3. Install the Etherenet bulkhead to the left hole in front panel
2. Connect all Electricity. 
	1. Use wiring diagram to run cables form power button, and power connector to the distribution PCB
	2. Connect two barrel jacks to the same board as in wiring diagram
3. Use m5x? screws and nuts to connect the Battery assembly to the inner bottom and the feet to  the outer bottom of the box.
6. Install both N-SMA bulkheads to the antenna side. 
7. Install a large LED to the antenna side middle hole. Use silicone for this hole. 
8. Install inner antennas
	1. Stick the LTE antennas about 5mm below omnia rails
	2. Install client Wifi antennas 
		1. Two are stuck to antenna side from inside
		2. two are perpendicular to this almost at the bottom