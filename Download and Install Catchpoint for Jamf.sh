#!/bin/zsh


## This will download and install the latest version of Catchpoint from Catchpoints servers
## Adjust license key to value supplied for catchpoint instance

## Created by Harry Richman, December 2020
## Version 1, revision 2

dmgfile="catchpoint.dmg"
app="Catchpoint"
url="https://fs.catchpoint.com/cpue/cpue_latest.dmg"

echo "`date` Downloading $app"
## Download silently and allow redirects
curl -L -s -o  /tmp/${dmgfile} ${url}

echo "`date` Mounting disk"
## Silently mount DMG
hdiutil attach /tmp/${dmgfile} -nobrowse -quiet

## Get volume name
volname=$( /bin/df | /usr/bin/grep "Catchpoint" | awk '{print $9}' )
echo "volume is $volname"

# Get name of installer.app
installerName=$( ls $volname )
echo "installer is $installerName"

echo "`date` Installing $app"
## Install application silently
### Using installbuilder.sh is not documented by Catchpoint. This is the only method of performing a silent install on mac OS
## Set $4 varibale in Jamf to be the license key for linking
sudo "${volname}/${installerName}/Contents/MacOS/installbuilder.sh" --mode unattended --update_mode 0 --cpue_license $4

sleep 15

echo "`date` Unmounting disk"
## Unmount volume
hdiutil detach $(/bin/df | /usr/bin/grep "${volname}" | awk '{print $1}') -quiet

sleep 10

echo "`date` Deleting disk"
## Delete disk image and clean up
rm /tmp/"${dmgfile}"

echo "`date` $app installed"

exit 0