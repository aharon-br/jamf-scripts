#!/bin/zsh

## Harry Richman
## Created February 2021
## Version 1.0
## Script will download latest Anaconda installer from Anaconda and install

app="Anaconda"
date=$( date | awk '{print $1, $2, $3, $4, $6}' | sed -e 's/[[:space:]]/- /g' | tr -d " " )  
serial=$( /usr/sbin/ioreg -l | /usr/bin/awk '/IOPlatformSerialNumber/ { print $4;}' | /usr/bin/tr -d '"' )

currentVersion=$( curl -s https://www.anaconda.com/products/individual | egrep -o "Python [[:digit:]]{1,3}.[[:digit:]]{1,3}" | head -1 )

downloadURL=$( curl -s https://www.anaconda.com/products/individual | egrep -o "https://repo.anaconda.com/archive/Anaconda3-[[:digit:]]{1,4}.[[:digit:]]{1,3}-MacOSX-x86_64.pkg" )

## If anaconda is already installed, remove the anaconda directory in /opt before installing again
if [[ -d /opt/anaconda3 ]]
then
	echo "${date} Anaconda 3 already installed, removing anaconda directory"
	rm -rf /opt/anaconda3
fi
## Download the latest package
echo "${date} Downloading ${app} ${currentVersion}"
curl -s -L -k -o /tmp/$app.pkg "$downloadURL"
## Install downloaded package
echo "${date} installing ${app} ${currentVersion}"
installer -allowUntrusted -pkg /tmp/$app.pkg -target /
sleep 5
echo "${date} ${app} ${currentVersion} installed"
## Delete downloaded package
echo "${date} Deleting ${app} Package"
rm -rf /tmp/$app.pkg
echo "${date} ${app} installed"
exit 0