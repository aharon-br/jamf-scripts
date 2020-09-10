#!/bin/bash

## Harry Richman
## Version 1.0
## Script will download latest Micosoft Installer from Microsofts CDN and install

# Download URLS from macadmins.software
## Office 2019 URLS (as of May 2020)
## Full Office https://go.microsoft.com/fwlink/?linkid=525133
###  Word https://go.microsoft.com/fwlink/?linkid=525134
#### Excel https://go.microsoft.com/fwlink/?linkid=525135
##### PowerPoint https://go.microsoft.com/fwlink/?linkid=525136 
downloadURL="https://go.microsoft.com/fwlink/?linkid=525135"
# Change App Name here - could instead use $4 in Jamf and variable in Jamf
app="Excel"
date="date"


echo "`date` Downloading Latest Microsoft ${app}"
/usr/bin/curl -L -k -o /tmp/$app.pkg "$downloadURL"
echo "installing Microsoft ${app}"
/usr/sbin/installer -allowUntrusted -pkg /tmp/$app.pkg -target /
sleep 15
echo "Micosoft ${app} installed"
echo "Deleting Microsoft ${app} Package"
rm -rf /tmp/$app.pkg
echo "`date` Microsoft ${app} Updated to `defaults read /Applications/Microsoft\ ${app}.app/Contents/Info CFBundleShortVersionString`"
exit 0