#!/bin/zsh


## This will download and copy to applications folder latest version of Viscosity directly from the developer website
## It will install the helper tool without requiring user intervention
## Created by Harry Richman July 2020
## Last updated by Harry Richman July 2020 
## version 2

dmgfile="viscosity.dmg"
volname="Viscosity"

## Get current version from website
currentVersion=$( curl -s 'https://www.sparklabs.com/viscosity/download/' | grep -o "Version [0-9]\.[0-9]\.[0-9]" | tr -d "Version " | head -1 )

## Check is Viscosity is installed or not and to show installed version if it is already
if [ ! -f "/Applications/Viscosity.app/Contents/Info.plist" ] ; then
	echo "`date` Viscosity isn't installed"
else
	## Get installed version from plist
	installedVersion=$( defaults read "/Applications/Viscosity.app/Contents/Info.plist" CFBundleShortVersionString )
	echo "`date` Installed version $installedVersion, current version is $currentVersion"
fi

## Remove previous copy of Viscosity
echo "`date` removing Viscosity ${currentVersion}"
rm -rf /Applications/Viscosity.app


## URL to download DMG from
url='https://www.sparklabs.com/downloads/Viscosity.dmg'
## Log date & time
echo "`date` Downloading Viscosity $currentVersion"
## Download silently and allow redirects
curl -L -s -o  /tmp/${dmgfile} ${url}
echo "`date` Mounting disk"
## Silently mount DMG
hdiutil attach /tmp/${dmgfile} -nobrowse -quiet
echo "`date` Copying to applications"
## Copy app bundle from disk image to Applications folder
ditto -rsrc "/Volumes/${volname}/Viscosity.app" "/Applications/Viscosity.app"
sleep 10
echo "`date` Unmounting disk"
## Unmount volume
hdiutil detach $(/bin/df | /usr/bin/grep "${volname}" | awk '{print $1}') -quiet
sleep 10
echo "`date` Deleting disk"
## Delete disk image
rm /tmp/"${dmgfile}"

## Install Helper Tool without user interaction
/Applications/Viscosity.app/Contents/MacOS/Viscosity -installHelperTool YES


exit 0