# raspberry
## Scripts for setup raspberryPi
Here are some short Scripts for setup a new raspberry und do some configuration inside.
All scripts are designed more or less from the FHEM point of view.
After download - the script should be executed with bash and sudo.
```
sudo bash <scriptname>
```
Short description the Basic Script in sort of usage:

* Basic   will setup all Basic things like last software, language, hostname
* Uart    will prepare the Pi for using an GPIO UART Modul and keep onboard Wlan & BT running
* Samba   will setup a samba Server with an open share for using Sonos Text2Speech
* Davfs   will setup the usage of a WebDav cloud service like magenta
* Fhem    will setup FHEM "the easy way" & Softwarepacks from the fhem*.txt Files and make some basic configuration too
* Docker  will setup Docker and docker-compose
* PiVCCU  will setup System Components for Raspberrymatic
* Prereq  will setup quick and easy an FHEM System for Migration and test prerequisite (dependecies between fhem.cfg and perl libraries)
* Ser2net will setup ser2net service and configure it for building an remote GPIO UART Modul

Some extended Script for a ready System  
* configBackup...   Implement a Backup Solution wich copies the lokal Backup to a SMB Server and is triggered from FHEM
* setupNodejs         Simple install a defined Version of nodejs. Please look at https://nodejs.org/de/about/releases/
# Download a bunch of Scripts 
For FHEM directly
```
wget https://raw.githubusercontent.com/heinz-otto/raspberry/master/setup{Basic.sh,Uart.sh,Samba.sh,Fhem.sh,BackupFhem2Cifs.sh,Nodejs.sh}
```
For Docker
```
wget -N https://raw.githubusercontent.com/heinz-otto/raspberry/master/setup{Basic.sh,Uart.sh,BasisDocker.sh,PiVCCU.sh}
```
For system migration and testing
```
wget -N https://raw.githubusercontent.com/heinz-otto/raspberry/master/setup{Basic.sh,Uart.sh,Prereq.sh}
```
