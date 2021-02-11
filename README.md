# SOCIALCOUNTER

Raspberry Pi PowerShell project which displays the number of followers from your selected social network.

The code collects the number of followers and displays them on 8 character 7 segment display.

Use the following guide to setup Visual Code and install PowerShell to the Raspberry PI: https://www.slashadmin.co.uk/how-to-develop-powershell-scripts-for-the-raspberry-pi/

![alt text](https://github.com/slashadminsource/SocialCounter/blob/master/images/front.jpg?raw=true)

![alt text](https://github.com/slashadminsource/SocialCounter/blob/master/images/back.jpg?raw=true)
![alt text](https://github.com/slashadminsource/SocialCounter/blob/master/images/back2.jpg?raw=true)

# PARTS

- Any Raspberry PI
- MAX7219 8-Digit Red LED Display Control Module display here is one on amazon: https://www.amazon.co.uk/HALJIA-MAX7219-8-Digit-Display-Control/dp/B076K71XC9/ref=sr_1_13?crid=2PVL79G5V1QM4&dchild=1&keywords=7+segment+display+module&qid=1613037805&sprefix=7+segment+display%2Caps%2C183&sr=8-13
- 5 push buttons anything like this will do: https://www.amazon.co.uk/RUNCCI-Button-Switch-Momentary-250V%EF%BC%88no/dp/B07N1N1T7R/ref=sr_1_1?dchild=1&keywords=push+button&qid=1613037885&sr=8-1

# SETUP STEPS

- Hookup five buttons and the display module. 
- Install PowerShell to the Raspberry PI following the guide above. 
- Place the socialcounter.ps1 and settings.cfg files to a location in your scripts folder. 
- Setup the script to run automatically.

  

# HOOKUP PARTS

Buttons

- Button 1 = Back = Connect to pin 37
- Button 2 = Up = Connect to pin 35
- Button 3 = Down = Connect to pin 33
- Button 4 = Select = Connect to pin 38 
- Button 5 = Exit = Connect to pin 36

Display Module

- VCC =  Connect to pin 17 
- GND = Connect to pin 25 
- DOUT = Connect to pin 19 
- LOAD = Connect to pin 24 
- CLK = Connect to pin 23

# SETUP THE SCRIPT TO AUTORUN

```
Open up the rc.local file under the /etc folder.
Add the following line before the exit 0 command and update it to point to your script location
sudo /usr/bin/pwsh -File /home/pi/scripts/SocialCounter.ps1
Here is what mine looks like:
```

```
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

# Print the IP address
_IP=$(hostname -I) || true
if [ "$_IP" ]; then
  printf "My IP address is %s\n" "$_IP"
fi

sudo /usr/bin/pwsh -File /home/pi/scripts/DisplayDemo4.ps1

exit 0
```

Once you save the file and reboot the Raspberry PI should boot up and run the script automatically.
